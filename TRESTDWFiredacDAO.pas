unit TRESTDWFiredacDAO;

interface

uses
  FireDAC.Stan.StorageBin,
  System.SysUtils, System.Classes, Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.Comp.UI,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, System.TypInfo, System.Variants,
  uRestDWDataModule, uRESTDWServerEvents,
  uRESTDWParams, uRESTDWBasic, uRESTDWConsts;

type

  [ComponentPlatforms(pidAllPlatforms)]
  TRESTDWClientSQLFD = class(TFDQuery)
  private
    vClientEvents: TRESTDWClientEvents;
    vClientPooler: TRESTClientPoolerBase;
    vServerDataModuleClass: string;
    vServerConnectionComponent: string;
    vOwner: TComponent;
    vRowsAffectedRemote: Int64;
    procedure SetRESTDWClientPooler(const value: TRESTClientPoolerBase);
    procedure SetServerConnectionComponent(const value: string);
    procedure SetServerDataModuleClass(const value: string);
    procedure RebuildParams(ParamCount: integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OpenRemote;
    procedure ApplyUpdatesRemote;
    procedure ExecSQLRemote;
  published
    property RowsAffectedRemote: Int64 read vRowsAffectedRemote;
    property ClientPooler: TRESTClientPoolerBase read vClientPooler
      write SetRESTDWClientPooler;
    property ServerDataModuleClass: string read vServerDataModuleClass
      write SetServerDataModuleClass;
    property ServerConnectionComponent: string read vServerConnectionComponent
      write SetServerConnectionComponent;
  end;

type

  TOnQueryError = procedure(ASender, AInitiator: TObject; var AException: Exception)
    of object;
  TOnQueryAfterOpen = procedure(DataSet: TDataSet) of object;

  [ComponentPlatforms(pidAllPlatforms)]
  TRESTDWConnectionFD = class(TFDConnection)
  private
    vServerEvents: TRESTDWServerEvents;
    vOwner: TComponent;
    vOnQueryError: TOnQueryError;
    vOnQueryAfterOpen: TOnQueryAfterOpen;
    vDriverName: String;
    procedure RESTDWServerEvents1EventsQueryReplyEvent(var Params: TRESTDWParams;
      const Result: TStringList);
    procedure SetOnQueryError(const value: TOnQueryError);
    procedure SetOnQueryAfterOpen(const value: TOnQueryAfterOpen);
    procedure SetDriverName(const value: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property OnQueryError: TOnQueryError read vOnQueryError write SetOnQueryError;
    property OnQueryAfterOpen: TOnQueryAfterOpen read vOnQueryAfterOpen
      write SetOnQueryAfterOpen;
    property DriverName: String read vDriverName write SetDriverName;
  end;

procedure Register;

implementation

{ TRESTDWClientSQLFD }

constructor TRESTDWClientSQLFD.Create(AOwner: TComponent);
begin
  vOwner := nil;
  vClientEvents := nil;

  vOwner := AOwner;

  inherited;
end;

destructor TRESTDWClientSQLFD.Destroy;
begin
  if ((Assigned(vOwner) = false) or not(csDesigning in vOwner.ComponentState)) then
    FreeAndNil(vClientEvents);

  Finalize(vServerDataModuleClass);
  Finalize(vServerConnectionComponent);

  inherited;
end;

procedure TRESTDWClientSQLFD.ExecSQLRemote;
var
  vBinaryWriter: TBinaryWriter;
  vStreamAux: TMemoryStream;
  vStringStreamAux: TStringStream;
  vBytesAux: TArray<Byte>;
  i, x, t: integer;
  vRestParams: TRESTDWParams;
  vErrorMessage: string;
begin
  try
    try
      vBinaryWriter := nil;
      vStreamAux := nil;
      vStringStreamAux := nil;
      vRestParams := nil;
      vErrorMessage := '';

      vStreamAux := TMemoryStream.Create;
      vBinaryWriter := TBinaryWriter.Create(vStreamAux);
      vStringStreamAux := TStringStream.Create(SQL.Text, TEncoding.UTF8);

      RebuildParams(Self.Params.Count);

      vClientEvents.CreateDWParams('Query', vRestParams);

      vStringStreamAux.Position := 0;
      vRestParams.ItemsString['SQL'].LoadFromStream(vStringStreamAux);

      vRestParams.ItemsString['ParamCount'].AsInteger := Self.Params.Count;

      for i := 0 to Self.Params.Count - 1 do
      begin
        SetLength(vBytesAux, Self.Params[i].GetDataSize);

        Self.Params[i].GetData(PByte(vBytesAux));

        if ((Self.Params[i].IsNull = false) and
          (VarType(Self.Params[i].value) = varString)) then
        begin
          t := 0;

          for x := Self.Params[i].GetDataSize - 1 downto 0 do
          begin
            if vBytesAux[x] = 0 then
              t := t + 1
            else
              break;
          end;

          SetLength(vBytesAux, Length(vBytesAux) - t);
        end;

        vRestParams.ItemsString['N' + i.ToString].AsBoolean := Self.Params[i].IsNull;

        vStreamAux.Clear;

        vBinaryWriter.Write(vBytesAux);

        vStreamAux.Position := 0;

        vRestParams.ItemsString['P' + i.ToString].LoadFromStream(vStreamAux);

        vRestParams.ItemsString['F' + i.ToString].AsString :=
          GetEnumName(Typeinfo(TFieldType), Ord(Self.Params[i].DataType));
      end;

      vRestParams.ItemsString['Type'].AsInteger := 2;

      vClientEvents.SendEvent('Query', vRestParams, vErrorMessage);

      if StringReplace(StringReplace(vErrorMessage, #$D#$A, '', [rfReplaceAll]), '"', '',
        [rfReplaceAll]) = 'OK' then
      begin
        Self.vRowsAffectedRemote := vRestParams.ItemsString['AffectedRows'].AsLargeInt;
      end
      else
        raise Exception.Create(vErrorMessage);
    except
      on e: Exception do
      begin
        Self.Close;

        raise Exception.Create(e.Message);
      end;
    end;
  finally
    FreeAndNil(vBinaryWriter);
    FreeAndNil(vStreamAux);
    FreeAndNil(vStringStreamAux);
    FreeAndNil(vRestParams);
    Finalize(vErrorMessage);
  end;
end;

procedure TRESTDWClientSQLFD.ApplyUpdatesRemote;
var
  vAuxMemTable: TFDMemTable;
  vBinaryWriter: TBinaryWriter;
  vStreamAux: TMemoryStream;
  vStringStreamAux: TStringStream;
  vBytesAux: TArray<Byte>;
  i, x, t: integer;
  vRestParams: TRESTDWParams;
  vErrorMessage: string;
begin
  try
    try
      vBinaryWriter := nil;
      vStreamAux := nil;
      vStringStreamAux := nil;
      vRestParams := nil;
      vErrorMessage := '';
      vAuxMemTable := nil;

      vAuxMemTable := TFDMemTable.Create(Self);
      vStreamAux := TMemoryStream.Create;
      vBinaryWriter := TBinaryWriter.Create(vStreamAux);
      vStringStreamAux := TStringStream.Create(SQL.Text, TEncoding.UTF8);

      RebuildParams(Self.Params.Count);

      vClientEvents.CreateDWParams('Query', vRestParams);

      vStringStreamAux.Position := 0;
      vRestParams.ItemsString['SQL'].LoadFromStream(vStringStreamAux);

      vRestParams.ItemsString['ParamCount'].AsInteger := Self.Params.Count;

      for i := 0 to Self.Params.Count - 1 do
      begin
        SetLength(vBytesAux, Self.Params[i].GetDataSize);

        Self.Params[i].GetData(PByte(vBytesAux));

        if ((Self.Params[i].IsNull = false) and
          (VarType(Self.Params[i].value) = varString)) then
        begin
          t := 0;

          for x := Self.Params[i].GetDataSize - 1 downto 0 do
          begin
            if vBytesAux[x] = 0 then
              t := t + 1
            else
              break;
          end;

          SetLength(vBytesAux, Length(vBytesAux) - t);
        end;

        vRestParams.ItemsString['N' + i.ToString].AsBoolean := Self.Params[i].IsNull;

        vStreamAux.Clear;

        vBinaryWriter.Write(vBytesAux);

        vStreamAux.Position := 0;

        vRestParams.ItemsString['P' + i.ToString].LoadFromStream(vStreamAux);

        vRestParams.ItemsString['F' + i.ToString].AsString :=
          GetEnumName(Typeinfo(TFieldType), Ord(Self.Params[i].DataType));
      end;

      vRestParams.ItemsString['Type'].AsInteger := 1;

      vStreamAux.Clear;

      vAuxMemTable.Data := Self.Delta;

      vAuxMemTable.SaveToStream(vStreamAux, sfBinary);

      vStreamAux.Position := 0;

      vRestParams.ItemsString['Stream'].LoadFromStream(vStreamAux);

      vClientEvents.SendEvent('Query', vRestParams, vErrorMessage);

      if StringReplace(StringReplace(vErrorMessage, #$D#$A, '', [rfReplaceAll]), '"', '',
        [rfReplaceAll]) = 'OK' then
      begin
        Self.CommitUpdates;

        Self.vRowsAffectedRemote := vRestParams.ItemsString['AffectedRows'].AsLargeInt;
      end
      else
        raise Exception.Create(vErrorMessage);
    except
      on e: Exception do
      begin
        Self.Close;

        raise Exception.Create(e.Message);
      end;
    end;
  finally
    FreeAndNil(vAuxMemTable);
    FreeAndNil(vBinaryWriter);
    FreeAndNil(vStreamAux);
    FreeAndNil(vStringStreamAux);
    FreeAndNil(vRestParams);
    Finalize(vErrorMessage);
  end;
end;

procedure TRESTDWClientSQLFD.OpenRemote;
var
  vBinaryWriter: TBinaryWriter;
  vStreamAux: TMemoryStream;
  vStringStreamAux: TStringStream;
  vBytesAux: TArray<Byte>;
  i, x, t: integer;
  vRestParams: TRESTDWParams;
  vErrorMessage: string;
begin
  try
    try
      vBinaryWriter := nil;
      vStreamAux := nil;
      vStringStreamAux := nil;
      vRestParams := nil;
      vErrorMessage := '';

      vStreamAux := TMemoryStream.Create;
      vBinaryWriter := TBinaryWriter.Create(vStreamAux);
      vStringStreamAux := TStringStream.Create(SQL.Text, TEncoding.UTF8);

      RebuildParams(Self.Params.Count);

      vClientEvents.CreateDWParams('Query', vRestParams);

      vStringStreamAux.Position := 0;
      vRestParams.ItemsString['SQL'].LoadFromStream(vStringStreamAux);

      vRestParams.ItemsString['ParamCount'].AsInteger := Self.Params.Count;

      for i := 0 to Self.Params.Count - 1 do
      begin
        SetLength(vBytesAux, Self.Params[i].GetDataSize);

        Self.Params[i].GetData(PByte(vBytesAux));

        if ((Self.Params[i].IsNull = false) and
          (VarType(Self.Params[i].value) = varString)) then
        begin
          t := 0;

          for x := Self.Params[i].GetDataSize - 1 downto 0 do
          begin
            if vBytesAux[x] = 0 then
              t := t + 1
            else
              break;
          end;

          SetLength(vBytesAux, Length(vBytesAux) - t);
        end;

        vRestParams.ItemsString['N' + i.ToString].AsBoolean := Self.Params[i].IsNull;

        vStreamAux.Clear;

        vBinaryWriter.Write(vBytesAux);

        vStreamAux.Position := 0;

        vRestParams.ItemsString['P' + i.ToString].LoadFromStream(vStreamAux);

        vRestParams.ItemsString['F' + i.ToString].AsString :=
          GetEnumName(Typeinfo(TFieldType), Ord(Self.Params[i].DataType));
      end;

      vRestParams.ItemsString['Type'].AsInteger := 0;

      vClientEvents.SendEvent('Query', vRestParams, vErrorMessage);

      if StringReplace(StringReplace(vErrorMessage, #$D#$A, '', [rfReplaceAll]), '"', '',
        [rfReplaceAll]) = 'OK' then
      begin
        vStreamAux.Clear;

        vRestParams.ItemsString['Stream'].SaveToStream(vStreamAux);

        vStreamAux.Position := 0;

        if Assigned(Self.Connection) = false then
        begin
          Self.Connection := TFDConnection.Create(Self);
        end;

        Self.LoadFromStream(vStreamAux, TFDStorageFormat.sfBinary);

        Self.CachedUpdates := true;
      end
      else
        raise Exception.Create(vErrorMessage);
    except
      on e: Exception do
      begin
        Self.Close;

        raise Exception.Create(e.Message);
      end;
    end;
  finally
    FreeAndNil(vBinaryWriter);
    FreeAndNil(vStreamAux);
    FreeAndNil(vStringStreamAux);
    FreeAndNil(vRestParams);
    Finalize(vErrorMessage);
  end;
end;

procedure TRESTDWClientSQLFD.SetServerConnectionComponent(const value: string);
begin
  vServerConnectionComponent := value;

  if Assigned(vClientEvents) then
    vClientEvents.ServerEventName := vServerDataModuleClass + '.' +
      vServerConnectionComponent + 'Events';
end;

procedure TRESTDWClientSQLFD.SetServerDataModuleClass(const value: string);
begin
  vServerDataModuleClass := value;

  if Assigned(vClientEvents) then
    vClientEvents.ServerEventName := vServerDataModuleClass + '.' +
      vServerConnectionComponent + 'Events';
end;

procedure TRESTDWClientSQLFD.RebuildParams(ParamCount: integer);
var
  id, i: integer;
begin
  if ((Assigned(vOwner) = false) or not(csDesigning in vOwner.ComponentState)) then
  begin
    vClientEvents.Events.Clear;

    vClientEvents.Events.Add;
    vClientEvents.Events.Items[0].Name := 'Query';
    vClientEvents.Events.Items[0].OnlyPreDefinedParams := false;

    vClientEvents.Events.Items[0].Params.Clear;

    id := vClientEvents.Events.Items[0].Params.Add.id;
    vClientEvents.Events.Items[0].Params.Items[id].ParamName := 'Stream';
    vClientEvents.Events.Items[0].Params.Items[id].ObjectDirection :=
      TObjectDirection.odINOUT;
    vClientEvents.Events.Items[0].Params.Items[id].ObjectValue := TObjectValue.ovStream;
    vClientEvents.Events.Items[0].Params.Items[id].Encoded := false;

    id := vClientEvents.Events.Items[0].Params.Add.id;
    vClientEvents.Events.Items[0].Params.Items[id].ParamName := 'SQL';
    vClientEvents.Events.Items[0].Params.Items[id].ObjectDirection :=
      TObjectDirection.odINOUT;
    vClientEvents.Events.Items[0].Params.Items[id].ObjectValue := TObjectValue.ovStream;
    vClientEvents.Events.Items[0].Params.Items[id].Encoded := false;

    id := vClientEvents.Events.Items[0].Params.Add.id;
    vClientEvents.Events.Items[0].Params.Items[id].ParamName := 'Type';
    vClientEvents.Events.Items[0].Params.Items[id].ObjectDirection :=
      TObjectDirection.odINOUT;
    vClientEvents.Events.Items[0].Params.Items[id].ObjectValue := TObjectValue.ovInteger;
    vClientEvents.Events.Items[0].Params.Items[id].Encoded := false;

    id := vClientEvents.Events.Items[0].Params.Add.id;
    vClientEvents.Events.Items[0].Params.Items[id].ParamName := 'ParamCount';
    vClientEvents.Events.Items[0].Params.Items[id].ObjectDirection :=
      TObjectDirection.odINOUT;
    vClientEvents.Events.Items[0].Params.Items[id].ObjectValue := TObjectValue.ovInteger;
    vClientEvents.Events.Items[0].Params.Items[id].Encoded := false;

    id := vClientEvents.Events.Items[0].Params.Add.id;
    vClientEvents.Events.Items[0].Params.Items[id].ParamName := 'AffectedRows';
    vClientEvents.Events.Items[0].Params.Items[id].ObjectDirection :=
      TObjectDirection.odINOUT;
    vClientEvents.Events.Items[0].Params.Items[id].ObjectValue := TObjectValue.ovLargeint;
    vClientEvents.Events.Items[0].Params.Items[id].Encoded := false;

    for i := 0 to ParamCount - 1 do
    begin
      id := vClientEvents.Events.Items[0].Params.Add.id;
      vClientEvents.Events.Items[0].Params.Items[id].ParamName := 'P' + i.ToString;
      vClientEvents.Events.Items[0].Params.Items[id].ObjectDirection :=
        TObjectDirection.odINOUT;
      vClientEvents.Events.Items[0].Params.Items[id].ObjectValue := TObjectValue.ovStream;
      vClientEvents.Events.Items[0].Params.Items[id].Encoded := false;

      id := vClientEvents.Events.Items[0].Params.Add.id;
      vClientEvents.Events.Items[0].Params.Items[id].ParamName := 'F' + i.ToString;
      vClientEvents.Events.Items[0].Params.Items[id].ObjectDirection :=
        TObjectDirection.odINOUT;
      vClientEvents.Events.Items[0].Params.Items[id].ObjectValue := TObjectValue.ovString;
      vClientEvents.Events.Items[0].Params.Items[id].Encoded := false;

      id := vClientEvents.Events.Items[0].Params.Add.id;
      vClientEvents.Events.Items[0].Params.Items[id].ParamName := 'N' + i.ToString;
      vClientEvents.Events.Items[0].Params.Items[id].ObjectDirection :=
        TObjectDirection.odINOUT;
      vClientEvents.Events.Items[0].Params.Items[id].ObjectValue :=
        TObjectValue.ovBoolean;
      vClientEvents.Events.Items[0].Params.Items[id].Encoded := false;
    end;
  end;
end;

procedure TRESTDWClientSQLFD.SetRESTDWClientPooler(const value: TRESTClientPoolerBase);
begin
  vClientPooler := value;

  if ((Assigned(vOwner) = false) or not(csDesigning in vOwner.ComponentState)) then
  begin
    vClientEvents := TRESTDWClientEvents.Create(Self);

    vClientEvents.RESTClientPooler := vClientPooler;
    vClientEvents.RESTClientPooler.BinaryRequest := true;
  end;
end;

{ TRESTDWConnectionFD }

constructor TRESTDWConnectionFD.Create(AOwner: TComponent);
begin
  vServerEvents := nil;
  vOwner := nil;

  vOwner := AOwner;

  if ((Assigned(vOwner) = false) or (not(vOwner is TServerMethodDataModule))) then
    raise Exception.Create
      ('This component should be used in TServerMethodDataModule (aka RESTDW DataModule).');

  inherited;
end;

destructor TRESTDWConnectionFD.Destroy;
begin
  inherited;
end;

procedure TRESTDWConnectionFD.RESTDWServerEvents1EventsQueryReplyEvent
  (var Params: TRESTDWParams; const Result: TStringList);
var
  vQueryAux, vQueryAux2: TFDQuery;
  vAuxStream: TMemoryStream;
  vBinaryReader: TBinaryReader;
  vAuxParamStream: TMemoryStream;
  vAuxStringStream: TStringStream;
  vAuxPBytes: TArray<Byte>;
  i: integer;
begin
  try
    try
      vQueryAux := nil;
      vQueryAux2 := nil;
      vAuxStream := nil;
      vBinaryReader := nil;
      vAuxStringStream := nil;
      vAuxParamStream := nil;

      vAuxStream := TMemoryStream.Create;
      vAuxParamStream := TMemoryStream.Create;
      vBinaryReader := TBinaryReader.Create(vAuxParamStream);
      vAuxStringStream := TStringStream.Create('', TEncoding.UTF8);

      Params.ItemsString['SQL'].SaveToStream(vAuxStringStream);
      vAuxStringStream.Position := 0;

      vQueryAux := TFDQuery.Create(Self);
      vQueryAux.Connection := Self;
      vQueryAux.SQL.Text := vAuxStringStream.DataString;

      if Params.ItemsString['Type'].AsInteger = 1 then
      begin
        vQueryAux2 := TFDQuery.Create(Self);
        vQueryAux2.Connection := Self;
        vQueryAux2.SQL.Text := vAuxStringStream.DataString;
      end;

      if Params.ItemsString['ParamCount'].AsInteger > 0 then
      begin
        for i := 0 to Params.ItemsString['ParamCount'].AsInteger - 1 do
        begin
          vAuxParamStream.Clear;

          vAuxParamStream.Position := 0;

          Params.ItemsString['P' + i.ToString].SaveToStream(vAuxParamStream);

          vAuxParamStream.Position := 0;

          vAuxPBytes := vBinaryReader.ReadBytes(vAuxParamStream.Size);

          vAuxParamStream.Position := 0;

          vQueryAux.Params.Add;

          vQueryAux.Params[i].DataType :=
            TFieldType(GetEnumValue(Typeinfo(TFieldType),
            Params.ItemsString['F' + i.ToString].AsString));

          vQueryAux.Params[i].SetData(PByte(vAuxPBytes), Length(vAuxPBytes));

          if Params.ItemsString['N' + i.ToString].AsBoolean then
            vQueryAux.Params[i].Clear;

          if Params.ItemsString['Type'].AsInteger = 1 then
          begin
            vQueryAux2.Params.Add;

            vQueryAux2.Params[i].DataType :=
              TFieldType(GetEnumValue(Typeinfo(TFieldType),
              Params.ItemsString['F' + i.ToString].AsString));

            vQueryAux2.Params[i].SetData(PByte(vAuxPBytes), Length(vAuxPBytes));

            if Params.ItemsString['N' + i.ToString].AsBoolean then
              vQueryAux2.Params[i].Clear;
          end;
        end;
      end;

      if Assigned(vOnQueryError) then
        vQueryAux.OnError := vOnQueryError;

      if Assigned(vOnQueryAfterOpen) then
        vQueryAux.AfterOpen := vOnQueryAfterOpen;

      if Params.ItemsString['Type'].AsInteger = 1 then
      begin
        vQueryAux.Close;
        vQueryAux2.Close;

        vQueryAux.CachedUpdates := true;
        vQueryAux2.CachedUpdates := true;

        vQueryAux.Open;

        vAuxStream.Clear;

        Params.ItemsString['Stream'].SaveToStream(vAuxStream);

        vAuxStream.Position := 0;

        vQueryAux2.LoadFromStream(vAuxStream);

        vQueryAux.MergeDataSet(vQueryAux2, dmDeltaMerge);

        vQueryAux.ApplyUpdates;

        Params.ItemsString['AffectedRows'].AsLargeInt :=
          vQueryAux2.Delta.DataView.Rows.Count;

        vQueryAux.CommitUpdates;

        vQueryAux.CachedUpdates := false;
      end
      else if Params.ItemsString['Type'].AsInteger = 0 then
      begin
        vQueryAux.Open;

        vQueryAux.SaveToStream(vAuxStream, TFDStorageFormat.sfBinary);

        vAuxStream.Position := 0;

        Params.ItemsString['Stream'].LoadFromStream(vAuxStream);

        Params.ItemsString['AffectedRows'].AsLargeInt := vQueryAux.RowsAffected;

        vQueryAux.Close;
      end
      else if Params.ItemsString['Type'].AsInteger = 2 then
      begin
        vQueryAux.ExecSQL;

        Params.ItemsString['AffectedRows'].AsLargeInt := vQueryAux.RowsAffected;

        vQueryAux.Close;
      end;

      Result.Text := 'OK';
    except
      on e: Exception do
      begin
        Result.Text := e.Message;
      end;
    end
  finally
    FreeAndNil(vQueryAux);
    FreeAndNil(vAuxStream);
    FreeAndNil(vBinaryReader);
    FreeAndNil(vAuxStringStream);
    FreeAndNil(vAuxParamStream);
  end;
end;

procedure TRESTDWConnectionFD.SetDriverName(const value: string);
var
  id: integer;
begin
  if not(csDesigning in vOwner.ComponentState) then
  begin
    if Assigned(vServerEvents) then
    begin
      FreeAndNil(vServerEvents);
    end;

    vServerEvents := TRESTDWServerEvents.Create(vOwner);

    vServerEvents.Name := Self.Name + 'Events';

    vServerEvents.Events.Clear;

    vServerEvents.Events.Add;
    vServerEvents.Events.Items[0].Name := 'Query';
    vServerEvents.Events.Items[0].OnlyPreDefinedParams := false;

    vServerEvents.Events.Items[0].Params.Clear;

    id := vServerEvents.Events.Items[0].Params.Add.id;
    vServerEvents.Events.Items[0].Params.Items[id].ParamName := 'Stream';
    vServerEvents.Events.Items[0].Params.Items[id].ObjectDirection :=
      TObjectDirection.odINOUT;
    vServerEvents.Events.Items[0].Params.Items[id].ObjectValue := TObjectValue.ovStream;
    vServerEvents.Events.Items[0].Params.Items[id].Encoded := false;

    id := vServerEvents.Events.Items[0].Params.Add.id;
    vServerEvents.Events.Items[0].Params.Items[id].ParamName := 'SQL';
    vServerEvents.Events.Items[0].Params.Items[id].ObjectDirection :=
      TObjectDirection.odINOUT;
    vServerEvents.Events.Items[0].Params.Items[id].ObjectValue := TObjectValue.ovStream;
    vServerEvents.Events.Items[0].Params.Items[id].Encoded := false;

    id := vServerEvents.Events.Items[0].Params.Add.id;
    vServerEvents.Events.Items[0].Params.Items[id].ParamName := 'Type';
    vServerEvents.Events.Items[0].Params.Items[id].ObjectDirection :=
      TObjectDirection.odINOUT;
    vServerEvents.Events.Items[0].Params.Items[id].ObjectValue := TObjectValue.ovInteger;
    vServerEvents.Events.Items[0].Params.Items[id].Encoded := false;

    id := vServerEvents.Events.Items[0].Params.Add.id;
    vServerEvents.Events.Items[0].Params.Items[id].ParamName := 'ParamCount';
    vServerEvents.Events.Items[0].Params.Items[id].ObjectDirection :=
      TObjectDirection.odINOUT;
    vServerEvents.Events.Items[0].Params.Items[id].ObjectValue := TObjectValue.ovInteger;
    vServerEvents.Events.Items[0].Params.Items[id].Encoded := false;

    id := vServerEvents.Events.Items[0].Params.Add.id;
    vServerEvents.Events.Items[0].Params.Items[id].ParamName := 'AffectedRows';
    vServerEvents.Events.Items[0].Params.Items[id].ObjectDirection :=
      TObjectDirection.odINOUT;
    vServerEvents.Events.Items[0].Params.Items[id].ObjectValue := TObjectValue.ovLargeint;
    vServerEvents.Events.Items[0].Params.Items[id].Encoded := false;

    vServerEvents.Events.Items[0].OnReplyEvent :=
      RESTDWServerEvents1EventsQueryReplyEvent;
  end;

  TFDConnection(Self).DriverName := value;
end;

procedure TRESTDWConnectionFD.SetOnQueryAfterOpen(const value: TOnQueryAfterOpen);
begin
  vOnQueryAfterOpen := value;
end;

procedure TRESTDWConnectionFD.SetOnQueryError(const value: TOnQueryError);
begin
  vOnQueryError := value;
end;

{ Register Components }

procedure Register;
begin
  RegisterComponents('REST Dataware - DAO', [TRESTDWClientSQLFD, TRESTDWConnectionFD]);
end;

end.
