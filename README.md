# Projeto Cloud
**Desenvolvido por:** Ricardo Israel

## Descrição do projeto
O principal objetivo do projeto é proteger e garantir a segurança de dados sensíveis em uma aplicação ECS, mantendo segredos criptografados em um gerenciador de segredos em vez de coloca-los diretamente no código. Produtos da AWS como o AWS Secret Manager e o AWS KMS são responsáveis por gerenciar as informaçoes confidenciais e criptografar e descriptografar os segredos de forma segura e eficiente, respectivamente.

Como os segredos não são revelados no código da aplicação, essa estratégia possui várias vantagens em termos de segurança, pois reduz significativamente a probabilidade de vazamentos e ataques cibernéticos. Além disso, o uso do AWS Secret Manager e do AWS KMS permite que os segredos sejam rotacionados com facilidade e segurança, sem a necessidade de alterar o código da aplicação.

## Como rodar o projeto
No arquivo ```main.tf```, é necessário trocar o nome do *secret manager* (linha 84) para um nome que náo existe ainda. O nome pode ser o que vocë quiser, mas como sugestáo, use o nome:
- "example-17-pwetty-please", aumentando uma unidade no número a cada novo teste.

A seguir, os 3 principais comandos do terraform para subir a aplicação:
- ```terraform init```
- ```terraform plan```
- ```terraform apply``` (náo se esqueça de escrever "yes" na hora de digitar um valor)

vale lembrar que é necessario ter o terraform instalado na maquina e esses comando rodados dentro da pasta do projeto.

Após o apply, haverá um link como output, no próprio terminal, na varialvel ```elb_public_ip```.

Copie esse link e cole em uma nova aba de um navegador.

Haverá um "Hello, World!" na tela. Isso significa que você conseguiu acesso ao secret com sucesso e consequentemente servindo com êxito. 

## Passo a passo do ```main.tf```
### 1. Provider
O provider é a AWS. Para usar, é necessário ter uma conta na AWS e configurar as credenciais no arquivo. Para isso, é necessário ter o AWS CLI instalado e configurado. Para configurar, basta rodar o comando ```aws configure``` e seguir os passos.

### 2. VPC
A VPC é a rede virtual onde os recursos serão alocados. Para isso, é necessário criar uma VPC, duas subnet, no meu caso, e uma internet gateway. A subnet é a rede onde os recursos serão alocados. A internet gateway é a porta de entrada para a internet.
- VPC: ```main.tf``` linhas 5-12
- Subnet1: ```main.tf``` linhas 14-24
- Subnet2: ```main.tf``` linhas 26-36
- Internet Gateway: ```main.tf``` linhas 38-50

### 3. Security Group
O security group é o grupo de segurança que define as regras de entrada e saída de dados. É definir as regras de entrada e saída.
- Ingress: ```main.tf``` linhas 57-62 (Regras de entrada, no meu caso, só permitindo acesso pela porta 80)
- Egrees: ```main.tf``` linhas 64-69 (Regras de saída, no meu caso, permitindo acesso a qualquer porta)
- Tags: ```main.tf``` linhas 71-74 (Tags para identificar o security group)

### 4. KMS
O KMS é o Key Management Service, que é o serviço de gerenciamento de chaves. Para isso, é necessário criar uma chave e definir as regras de acesso.
- Criacao da chave: ```main.tf``` linhas 78-80 (nome = "example", essa chave será usada para criptografar o secret que sao armazenados no secret manager)
- Criacao do segredo: ```main.tf``` linhas 82-86 (nome = "example-16-pwetty-please", kms_ket_id indica qual chave será usada para criptografar o secret)
-Criacao de um exemplo de segredo: ```main.tf``` linhas 88-92 (secret_string indica o conteúdo do secret que esta dentro de um arquivo chamado "secrets.json")
- Politica de acesso: ```main.tf``` linhas 94-112 (essa politica permite o principal (no caso, a funcao IAM com ARN especifico) a acessar a chave criada anteriormente)

### 5. IAM
O IAM é o Identity and Access Management, que é o serviço de gerenciamento de identidade e acesso. Para isso, é necessário criar uma função e definir as regras de acesso.
-Definicao da Role: ```main.tf``` linhas 115-131 (nome = "example-ecs-task-execution", assume_role_policy = jsonencode indica a politica de acesso que a funcao terá que nesse caso é um objeto json)
- Politica de acesso: ```main.tf``` linhas 133-166 (Cria uma politica para ser associada a Role criada anteriormente. Por exemplo, nesse caso, obter os segredos do secret manager e descriptografar e usar o segredo com KMS)
-Associacao da Polita a Role: ```main.tf``` linhas 185-189 (Associa a politica criada anteriormente a Role criada anteriormente)

### 6. ECS Fargate
O ECS Fargate é o serviço de container da AWS. Para isso, é necessário criar um cluster e uma task definition.
- Cluster: ```main.tf``` linhas 191-194 (Defifinicao do cluster com nome "example-cluster")
- Task Definition: ```main.tf``` linhas 196-242 (Definicao da task definition do ECS Fargate, alguns detalhes especificados nessa seção sao: mapeamento da porta 80 do container para a porta 80 do host, segredo que sera usado pelo container como credencial de acesso, entre outras.)
- CloudWatch Log Group: ```main.tf``` linhas 244-246 (Definicao do log group com nome "/ecs/example", que sera usado para armazenar os logs do container)
- Security Group: ```main.tf``` linhas 249-271 (Definicao do security group com nome "example-ecs-sg", que sera usado para controlar o trafego de rede do container. Ingress e Egress sao as regras de entrada e saida, respectivamente.)

### 7. ECS
O ECS é o Elastic Container Service, que é o serviço de container da AWS. Para isso, é necessário criar um service.
- Criacao do serviço: ```main.tf``` linhas 275-295 (launch_type = "FARGATE" indica que o tipo de lancamento sera o Fargate, load_balancer indica que o container sera acessado por um load balancer)

### 8. Load Balancer
O Load Balancer é o balanceador de carga da AWS. Para isso, é necessário criar um load balancer.
- Criacao do load balancer: ```main.tf``` linhas 297-304 (serve para balancear a carga de acesso ao container, no meu caso, o tipo de load balancer é o application)
- Target Group: ```main.tf``` linhas 306-324 (serve para definir o grupo de destino do load balancer, no meu caso, o tipo de target group é o ip)
- Listener: ```main.tf``` linhas 327-336 (serve para definir o ouvinte do load balancer, no meu caso, o tipo de listener é o http na porta 80)
- Gateway: ```main.tf``` linhas 338-340 (serve para definir o gateway do load balancer, no meu caso, o tipo de gateway é o internet associado a vpc criada anteriormente)
- Rout Table: ```main.tf``` linhas 342-349 (serve para definir a tabela de roteamento na AWS)
- Rout Table Association: ```main.tf``` linhas 351-354 (serve para associar a tabela de roteamento VPC criada anteriormente)
- Output: ```main.tf``` linhas 356-359 (serve para definir a saida que exibe o DNS do load balancer)
