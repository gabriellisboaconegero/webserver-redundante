# Sobre o banco de dados
## Postgres
O banco escolhido foi o postgres, pela minha familiaridade, alta popularida e ser open source.
Foi necessario aprender o conceito de HA (High Availability) em postgres e os componentes neccessários para fazer
funcionar.
Após entender por cima e quais são os arquivos de configuração do postgres achei um docker-compose ja cmeçado e
adaptei para meu caso.

## Replicação
O método de replicação escolhido foi o streaming, por diversas vantagens. Sendo uma delas a facilidade de
começar.
