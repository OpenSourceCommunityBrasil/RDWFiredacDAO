object DMServer: TDMServer
  OnCreate = ServerMethodDataModuleCreate
  Encoding = esUtf8
  QueuedRequest = False
  Height = 260
  Width = 373
  object RESTDWConnectionFD: TRESTDWConnectionFD
    DriverName = ''
    Params.Strings = (
      'DriverID=SQLite'
      'Database=banco.db')
    ConnectedStoredUsage = []
    LoginPrompt = False
    OnQueryError = RESTDWConnectionFDQueryError
    OnQueryAfterOpen = RESTDWConnectionFDQueryAfterOpen
    Left = 160
    Top = 104
  end
end
