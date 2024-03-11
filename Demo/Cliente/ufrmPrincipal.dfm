object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Cliente'
  ClientHeight = 441
  ClientWidth = 662
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 662
    Height = 91
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object Shape1: TShape
      Left = 0
      Top = 90
      Width = 662
      Height = 1
      Align = alBottom
      Pen.Color = clSilver
      ExplicitLeft = 48
      ExplicitTop = 16
      ExplicitWidth = 65
    end
    object btnOpen: TButton
      Left = 17
      Top = 8
      Width = 105
      Height = 48
      Caption = 'OpenRemote'
      TabOrder = 0
      OnClick = btnOpenClick
    end
    object btnExecSQL: TButton
      Left = 134
      Top = 8
      Width = 161
      Height = 48
      Caption = 'ExecSQLRemote'
      TabOrder = 1
      OnClick = btnExecSQLClick
    end
    object btnAppendApplyUpdate: TButton
      Left = 308
      Top = 8
      Width = 161
      Height = 48
      Caption = 'Append + ApplyUpdateRemote'
      TabOrder = 2
      WordWrap = True
      OnClick = btnAppendApplyUpdateClick
    end
    object DBNavigator1: TDBNavigator
      Left = 0
      Top = 65
      Width = 662
      Height = 25
      DataSource = DataSource
      Align = alBottom
      TabOrder = 3
      ExplicitLeft = 184
      ExplicitTop = 50
      ExplicitWidth = 360
    end
    object btnApplyUpdate: TButton
      Left = 483
      Top = 8
      Width = 161
      Height = 48
      Caption = 'ApplyUpdateRemote'
      TabOrder = 4
      OnClick = btnApplyUpdateClick
    end
  end
  object pnlGrid: TPanel
    Left = 0
    Top = 91
    Width = 662
    Height = 350
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 50
    ExplicitHeight = 391
    object DBGrid1: TDBGrid
      Left = 0
      Top = 0
      Width = 662
      Height = 350
      Align = alClient
      BorderStyle = bsNone
      DataSource = DataSource
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object RESTDWClientSQLFD: TRESTDWClientSQLFD
    SQL.Strings = (
      'SELECT * FROM tb_cidade')
    ClientPooler = RESTDWIdClientPooler
    ServerDataModuleClass = 'TDMServer'
    ServerConnectionComponent = 'RESTDWConnectionFD'
    Left = 216
    Top = 128
  end
  object RESTDWIdClientPooler: TRESTDWIdClientPooler
    DataCompression = True
    Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    ContentEncoding = 'gzip, identity'
    ContentType = 'application/x-www-form-urlencoded'
    Charset = 'utf8'
    Encoding = esUtf8
    EncodedStrings = True
    ThreadRequest = False
    Host = 'localhost'
    AuthenticationOptions.AuthorizationOption = rdwAOBasic
    AuthenticationOptions.OptionParams.AuthDialog = True
    AuthenticationOptions.OptionParams.CustomDialogAuthMessage = 'Protected Space...'
    AuthenticationOptions.OptionParams.Custom404TitleMessage = '(404) The address you are looking for does not exist'
    AuthenticationOptions.OptionParams.Custom404BodyMessage = '404'
    AuthenticationOptions.OptionParams.Custom404FooterMessage = 'Take me back to <a href="./">Home REST Dataware'
    AuthenticationOptions.OptionParams.Username = 'admin'
    AuthenticationOptions.OptionParams.Password = 'admin'
    RequestTimeOut = 10000
    ConnectTimeOut = 3000
    AllowCookies = False
    RedirectMaximum = 0
    HandleRedirects = False
    ProxyOptions.ProxyPort = 0
    FailOver = False
    UseSSL = False
    FailOverConnections = <>
    FailOverReplaceDefaults = False
    BinaryRequest = False
    CriptOptions.Use = False
    CriptOptions.Key = 'RDWBASEKEY256'
    UserAgent = 
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, l' +
      'ike Gecko) Chrome/41.0.2227.0 Safari/537.36'
    PoolerNotFoundMessage = 'Pooler not found'
    SSLVersions = []
    SSLMode = sslmUnassigned
    Left = 88
    Top = 128
  end
  object DataSource: TDataSource
    DataSet = RESTDWClientSQLFD
    Left = 315
    Top = 128
  end
end
