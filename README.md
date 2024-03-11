# RDWFiredacDAO
Esse componente é uma simples implementação do TFDQuery para ser usado no RestDataWare.


## Doações para esse projeto:
https://www.paypal.com/donate/?hosted_button_id=VVF2T2DWCKJQL

![QR Code](https://github.com/OpenSourceCommunityBrasil/RDWFiredacDAO/assets/92900717/d78c30c6-0d79-4367-8c78-577bc974d2b3)


## Limitações:
- Funciona apenas com RDW 2.1 ou superior;
- Funciona apenas em Delphi XE7 ou superior;
- Funciona apenas de FireDAC para FireDAC, ou sejam FireDAC no servidor e no cliente;


## Vantagens em relação ao ClientSQL padrão:
- Até 15 vezes mais rápido;
- Faz acesso DUAL, ou seja, o mesmo componente abre uma base remota e uma base local;
- Totalmente funcional: Indexes, Fields, Events, DBware, LiveBindings, RowsAffected,...
- Funciona Edit, Insert, Update, Delete, Navigation, ApplyUpdates, (DBWare/LiveBindings)...
- Pode ser executado Select (Open) ou Insert, Delete ou Update (ExecSQL) diretamente;
- Aceita parâmetros;
- Não utiliza a estrutura de PoolerDB do RestDataWare;
- Todas as informações trocadas são binarias, desde a coleta dos parâmetros, texto do SQL, resultados e deltas;


## Benchmark- FireDAC DAO x ClienSQL padrão:

![image](https://github.com/OpenSourceCommunityBrasil/RDWFiredacDAO/assets/92900717/c76bf8f7-d513-4c06-af14-5110cd8bdb83)
![image](https://github.com/OpenSourceCommunityBrasil/RDWFiredacDAO/assets/92900717/231c3569-3f75-4bb1-b18b-3b5c7640bf2e)
![image](https://github.com/OpenSourceCommunityBrasil/RDWFiredacDAO/assets/92900717/0f928d9e-760a-423e-b91e-d01e9ee0f907)


## Instalação:
Em um Delphi XE7 ou superior com RDW 2.1 ou superior já instalado, abra o projeto RESTDWFiredacDAO, compile e instale;
* Não esqueca de colocar no library path o diretório em que o código com componente foi salvo.

![image](https://github.com/OpenSourceCommunityBrasil/RDWFiredacDAO/assets/92900717/42c4d41f-1931-475c-9e8d-127684b5953f)


## Utilização no SERVIDOR:
- Coloque o componente RESTDWConnectionFD dentro o seu DataModule do RDW (ServerMethods);
- Configure um banco de dados no próprio componente, sem a necessidade de linkar com qualquer outro componente do RDW;
- A diferença dele para um FDConnection comum está apenas em 2 novos eventos que foram criados:
1) OnQueryAfterOpen: Executado sempre após uma abertura de query remota;
2) OnQueryError: Executado sempre que uma query gera erro;
* Esses 2 eventos servem para logar problemas de execução de query remota no servidor.
* Apenas UM componente por banco é necessário do lado do servidor. Apenas UM componente de RESTDWConnectionFD pode atender qualquer quantidade de RESTDWClientSQLFD.

![image](https://github.com/OpenSourceCommunityBrasil/RDWFiredacDAO/assets/92900717/a3c66079-68ab-43e1-8a51-084376b9c44c)

  
## Utilização no CLIENT:
- Coloque o componente RESTDWClientSQLFD no seu Form/DM;
- Link a propriedade ClientPooler com o Client Pooler do RDW que está no seu projeto;
- Preencha a propriedade ServerDataModuleClass com o nome da CLASSE do seu DataModule do RDW (ServerMethods) do servidor (Exemplo: TDataModule1);
- Preencha a propriedade ServerConnectionComponent com o nome do componente RESTDWConnectionFD que foi colocado dentro o seu DataModule do RDW (ServerMethods) do servidor (Exemplo: RESTDWConnectionFD1);
- Aqui você pode ajustar um conexão LOCAL ao seu componente para realizar acesso DUAL; A conxão local para acesso DUAL é OPCIONAL;
- Após tudo configurado, voce terá os seguintes comandos:
1) RESTDWClientSQLFD.OpenRemote: Abre a query no servidor e retorna;
2) RESTDWClientSQLFD.ExecSQLRemote: Abre o DML no servidor e retorna;
3) RESTDWClientSQLFD.ApplyUpdatesRemote: Aplica as alterações que foram feitas localmente no servidor;
4) RESTDWClientSQLFD.RowsAffectedRemote: Quantidade de linhas afetadas por um DML;
- Lembrando que se uma conexão DUAL estiver configurada voce pode fazer os mesmos comandos sem o sulfixo Remote para os dados locais;
- O componente RESTDWClientSQLFD pode ser usado como uma simples query de FireDAC, ou seja, aceitar tudo que a TFDQuery aceita;

![image](https://github.com/OpenSourceCommunityBrasil/RDWFiredacDAO/assets/92900717/ff15ee66-61c8-4f72-860d-c967454cad28)


## Migração de ClientSQL ou TFDQuery para o RESTDWClientSQLFD:
- Abra o PAS do seu projeto, insira na uses a unit RESTDWFiredacDAO;
- Ainda no PAS, altere o nome de todas as classes ClientSQL ou TFDQuery para RESTDWClientSQLFD;
- Abra o DFM e altere o nome de todas as classes ClientSQL ou TFDQuery para RESTDWClientSQLFD;
* Lembre-se de trocar o Open por OpenRemote, ExecSQL por ExecSQLRemote, ApplyUpdates para ApplyUpdatesRemote e RowsAffected por RowsAffectedRemote para casos em que queira buscar os dados no servidor;


