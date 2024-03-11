unit ufrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.WinXCtrls, uRESTDWAuthenticators,
  uRESTDWAbout, uRESTDWBasic, uRESTDWIdBase;

type
  TfrmPrincipal = class(TForm)
    ToggleSwitch: TToggleSwitch;
    RESTServicePooler: TRESTDWIdServicePooler;
    RESTDWAuthBasic: TRESTDWAuthBasic;
    procedure FormCreate(Sender: TObject);
    procedure ToggleSwitchClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses uDM;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  RESTServicePooler.ServerMethodClass := TDMServer;
  RESTServicePooler.Active := (ToggleSwitch.State = tssOn);
end;

procedure TfrmPrincipal.ToggleSwitchClick(Sender: TObject);
begin
  RESTServicePooler.Active := (ToggleSwitch.State = tssOn);
end;

end.
