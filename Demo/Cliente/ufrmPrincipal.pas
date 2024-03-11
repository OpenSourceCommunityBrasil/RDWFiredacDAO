unit ufrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, uRESTDWAbout,
  uRESTDWServerEvents, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  uRESTDWBasic, uRESTDWIdBase, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Comp.UI,
  Vcl.ExtCtrls, Vcl.DBCtrls, System.DateUtils, RESTDWFiredacDAO, Vcl.Buttons;

type
  TfrmPrincipal = class(TForm)
    RESTDWClientSQLFD: TRESTDWClientSQLFD;
    RESTDWIdClientPooler: TRESTDWIdClientPooler;
    DataSource: TDataSource;
    DBGrid1: TDBGrid;
    pnlTop: TPanel;
    btnOpen: TButton;
    btnExecSQL: TButton;
    btnAppendApplyUpdate: TButton;
    pnlGrid: TPanel;
    Shape1: TShape;
    DBNavigator1: TDBNavigator;
    btnApplyUpdate: TButton;
    procedure btnOpenClick(Sender: TObject);
    procedure btnExecSQLClick(Sender: TObject);
    procedure btnAppendApplyUpdateClick(Sender: TObject);
    procedure btnApplyUpdateClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

procedure TfrmPrincipal.btnOpenClick(Sender: TObject);
var
  INICIO, FIM: TDateTime;
begin

  INICIO := Now;

  RESTDWClientSQLFD.Close;
  RESTDWClientSQLFD.SQL.Clear;
  RESTDWClientSQLFD.SQL.Add(' SELECT * FROM tb_cidade WHERE 1 = 1 ');
  RESTDWClientSQLFD.OpenRemote; // OPEN

  FIM := Now;

  if (RESTDWClientSQLFD.Active) then
  begin
    Showmessage(IntToStr(RESTDWClientSQLFD.Recordcount) + ' registro(s) recebido(s) em ' +
      IntToStr(MilliSecondsBetween(FIM, INICIO)) + ' Milis.');
  end;
end;

procedure TfrmPrincipal.btnAppendApplyUpdateClick(Sender: TObject);
begin
  try
    if (RESTDWClientSQLFD.State in [dsBrowse]) then
    begin
      RESTDWClientSQLFD.Append;
      RESTDWClientSQLFD.FieldByName('Cod_Cidade').AsString := '67890';
      RESTDWClientSQLFD.FieldByName('Nome_Cidade').AsString :=
        '·ÈÌÛ˙¡…Õ”⁄‡ËÏÚ˘¿»Ã“Ÿ‰ÎÔˆ¸ƒÀœ÷‹„ı√’‚ÍÓÙ˚¬ Œ‘€Á«Ò—';
      RESTDWClientSQLFD.FieldByName('Sigla_Estado').AsString := 'AP';
      RESTDWClientSQLFD.ApplyUpdatesRemote; // APLLYUPDATES

      Showmessage('Registro gravado com sucesso.' + #13 + #13 + 'Foram alterados ' +
        RESTDWClientSQLFD.RowsAffectedRemote.ToString + ' registro(s).');
    end;
  except
    on E: Exception do
    begin
      Showmessage(E.Message);
    end;

  end;
end;

procedure TfrmPrincipal.btnApplyUpdateClick(Sender: TObject);
begin
  try
    if (RESTDWClientSQLFD.State in [dsBrowse]) then
    begin
      RESTDWClientSQLFD.ApplyUpdatesRemote; // APLLYUPDATES

      Showmessage('Registro gravado com sucesso.' + #13 + #13 + 'Foram alterados ' +
        RESTDWClientSQLFD.RowsAffectedRemote.ToString + ' registro(s).');
    end;
  except
    on E: Exception do
    begin
      Showmessage(E.Message);
    end;

  end;
end;

procedure TfrmPrincipal.btnExecSQLClick(Sender: TObject);
begin

  try
    RESTDWClientSQLFD.Close;
    RESTDWClientSQLFD.SQL.Clear;
    RESTDWClientSQLFD.SQL.Add
      (' INSERT INTO tb_cidade (Cod_Cidade, Nome_Cidade, Sigla_Estado )');
    RESTDWClientSQLFD.SQL.Add
      (' VALUES (:pCod_Cidade, :pNome_Cidade, :pSigla_Estado)          ');
    RESTDWClientSQLFD.ParamByName('pCod_Cidade').AsString := '12345';
    RESTDWClientSQLFD.ParamByName('pNome_Cidade').AsString :=
      '·ÈÌÛ˙¡…Õ”⁄‡ËÏÚ˘¿»Ã“Ÿ‰ÎÔˆ¸ƒÀœ÷‹„ı√’‚ÍÓÙ˚¬ Œ‘€Á«Ò—';
    RESTDWClientSQLFD.ParamByName('pSigla_Estado').AsString := 'EX';
    RESTDWClientSQLFD.ExecSQLRemote; // EXECSQL

    Showmessage('Registro gravado com sucesso.' + #13 + #13 + 'Foram alterados ' +
      RESTDWClientSQLFD.RowsAffectedRemote.ToString + ' registro(s).');
  except
    on E: Exception do
    begin
      Showmessage(E.Message);
    end;

  end;
end;

end.
