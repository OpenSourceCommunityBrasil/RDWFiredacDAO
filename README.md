# RDWFiredacDAO
Esse componente é uma simples implementação do TFDQuery para ser usado no RestDataWare.

Limitações:
- Funciona apenas com RDW 2.1 ou superior;
- Funciona apenas em Delphi XE7 ou superior;
- Funciona apenas de FireDAC para FireDAC, ou sejam FireDAC no servidor e no cliente;

Vantagens em relação ao ClientSQL padrão:
- Até 15 vezes mais rápido;
- Faz acesso DUAL, ou seja, o mesmo componente abre uma base remota e uma base local;
- Totalmente funcional: Indexes, Fields, Events, DBware, LiveBindings, RowsAffected,...
- Funciona Edit, Insert, Update, Delete, Navigation, ApplyUpdates, (DBWare/LiveBindings)...
- Pode ser executado Select (Open) ou Inser, Delete ou Update (ExecSQL) diretamente;
- Aceita parâmetros;
- Não utiliza a estrutura de PoolerDB do RestDataWare;
- Todas as informações trocadas são binarias, desde a coleta dos parâmetros, texto do SQL, resultados e deltas;

Benchmark- FireDAC DAO x ClienSQL padrão:

![image](https://github.com/OpenSourceCommunityBrasil/RDWFiredacDAO/assets/92900717/c76bf8f7-d513-4c06-af14-5110cd8bdb83)
![image](https://github.com/OpenSourceCommunityBrasil/RDWFiredacDAO/assets/92900717/231c3569-3f75-4bb1-b18b-3b5c7640bf2e)
![image](https://github.com/OpenSourceCommunityBrasil/RDWFiredacDAO/assets/92900717/0f928d9e-760a-423e-b91e-d01e9ee0f907)

Instalação:
Em um Delphi XE7 ou superior com RDW 2.1 ou superior já instalado, abra o projeto RESTDWFiredacDAO, compile e instale;
* Não esqueca de colocar no library path o diretório em que o código com componente foi salvo.

