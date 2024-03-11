object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Servidor'
  ClientHeight = 151
  ClientWidth = 261
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object ToggleSwitch: TToggleSwitch
    Left = 88
    Top = 48
    Width = 138
    Height = 20
    State = tssOn
    StateCaptions.CaptionOn = 'Servidor Online'
    StateCaptions.CaptionOff = 'Servidor Offline'
    TabOrder = 0
    OnClick = ToggleSwitchClick
  end
  object RESTServicePooler: TRESTDWIdServicePooler
    Active = False
    Authenticator = RESTDWAuthBasic
    CORS = False
    CORS_CustomHeaders.Strings = (
      'Access-Control-Allow-Origin=*'
      
        'Access-Control-Allow-Headers=Content-Type, Origin, Accept, Autho' +
        'rization, X-CUSTOM-HEADER')
    PathTraversalRaiseError = True
    RequestTimeout = -1
    ServicePort = 8082
    ProxyOptions.ProxyPort = 0
    Encoding = esUtf8
    RootPath = '/'
    ForceWelcomeAccess = False
    CriptOptions.Use = False
    CriptOptions.Key = 'RDWBASEKEY256'
    EncodeErrors = False
    ServerIPVersionConfig.IPv4Address = '0.0.0.0'
    ServerIPVersionConfig.IPv6Address = '::'
    SSLVerifyMode = []
    SSLVerifyDepth = 0
    SSLMode = sslmUnassigned
    SSLMethod = sslvSSLv2
    SSLVersions = []
    Left = 56
    Top = 88
  end
  object RESTDWAuthBasic: TRESTDWAuthBasic
    AuthDialog = True
    UserName = 'admin'
    Password = 'admin'
    Left = 168
    Top = 88
  end
end
