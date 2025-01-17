# Aplicação de webserver com redundância
## Componentes
- Dois webserver Python/Flask
- Dois bancos de dados postgressql com replicaçao por streaming
- Um loadbalancer dos servidores python em Nginx
- Pgpool para fazer o balanceamento e failover do banco
- Coletor de dados do host em Bash

## Funcionamento banco
Um banco primario é colocado no ar, depois que ele está configurado e ativo é feita uma cópia
com `pg_basebackup` para a replica e é criada a replicação por streaming entre eles.

Após ambos os bancos estarem ativos um container com o `pgpool` é levantado e configurado
para os dois bancos. Quando o banco principal falhar o `pgpool` vai acionar o failover e
avisar o banco replica para ser promovido.

O `pgpool` serve como porta de entrada para as conexões do coletor de dados e os servidores python.

## Os servidores
Ele servem um html básico com os dados atualizados do host. Além disso eles também retornam no html
de qual container o servidor está servindo e de qual banco foi feita a query.

Um servidor Nginx fica fazendo o balanceamento para os dois servidores.

## Observações
- Todas as aplicações tem acesso a todas as outras, não existem networks especificas para cada uma.
- As portas disponíveis são `9999` e `8080`. Onde a porta `9999` é a do `pgpool` para que coletor
possa inserir os dados no banco. A porta `8080` é para acessar o Nginx.
- A aplicação web não atualiza dinâmicamente as informações, apenas quando a página é recarregada.
