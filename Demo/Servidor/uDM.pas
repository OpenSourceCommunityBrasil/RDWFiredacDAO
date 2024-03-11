unit uDM;

interface

uses
  System.SysUtils, System.Classes, uRESTDWDatamodule, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.UI, System.DateUtils,
  RESTDWFiredacDAO, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat;

type
  TDMServer = class(TServerMethodDataModule)
    RESTDWConnectionFD: TRESTDWConnectionFD;
    procedure RESTDWConnectionFDQueryAfterOpen(DataSet: TDataSet);
    procedure RESTDWConnectionFDQueryError(ASender, AInitiator: TObject;
      var AException: Exception);
    procedure ServerMethodDataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    procedure CriarLog(pTexto: String);
  public
    { Public declarations }
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TDMServer.CriarLog(pTexto: String);
var
  CaminhoArquivoLog: string;
  ArquivoLog: TextFile;
  DataHora: string;
begin
  // Exemplo de criação de LOG para execução e erro de queries executadas
  // pelo client.
  // O LOG foi feito em TXT apenas para exemplificar, porém, para não impactar
  // a perforamnce do servidor, recomendamos gerar o log em uma tabela
  // no banco de dados usando uma transação diferente.

  CaminhoArquivoLog := GetCurrentDir + '\LogsQuery.txt';

  AssignFile(ArquivoLog, CaminhoArquivoLog);

  if FileExists(CaminhoArquivoLog) then
  begin
    Append(ArquivoLog);
  end
  else
  begin
    ReWrite(ArquivoLog);
  end;

  DataHora := FormatDateTime('dd-mm-yyyy_hh-nn-ss', Now);

  WriteLn(ArquivoLog, DateTimeToStr(Now) + ' -' + pTexto);

  CloseFile(ArquivoLog);
end;

procedure TDMServer.RESTDWConnectionFDQueryAfterOpen(DataSet: TDataSet);
begin
  // Evento OnQueryAfterOpen
  CriarLog(TFDQuery(DataSet).Text);
end;

procedure TDMServer.RESTDWConnectionFDQueryError(ASender, AInitiator: TObject;
  var AException: Exception);
begin
  // Evento OnQueryError
  CriarLog(AException.Message);
end;

procedure TDMServer.ServerMethodDataModuleCreate(Sender: TObject);
begin
  RESTDWConnectionFD.Params.Database := '../../DB/banco.db';
end;

end.
