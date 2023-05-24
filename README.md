# Projeto Cloud
**Desenvolvido por:** Ricardo Israel

## Como rodar o projeto
No arquivo ```main.tf```, é necessário trocar o nome do *secret manager* (linha 84) para um nome que náo existe ainda. O nome pode ser o que vocë quiser, mas como sugestáo, use o nome:
- "example-17-pwetty-please", aumentando uma unidade no número a cada novo teste.

A seguir, os 3 principais comandos do terraform para subir a aplicação:
- ```terraform init```
- ```terraform plan```
- ```terraform apply``` (náo se esqueça de escrever "yes" na hora de digitar um valor)

Após o apply, haverá um link como output, no próprio terminal, na varialvel ```elb_public_ip```.

Copie esse link e cole em uma nova aba.

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
O security group é o grupo de segurança que define as regras de entrada e saída de dados. Para isso, é necessário criar um security group e definir as regras de entrada e saída.
- Ingress: ```main.tf``` linhas 57-62 (Regras de entrada, no meu caso, só permitindo acesso pela porta 80)
- Egrees: ```main.tf``` linhas 64-69 (Regras de saída, no meu caso, permitindo acesso a qualquer porta)
- Tags: ```main.tf``` linhas 71-74 (Tags para identificar o security group)

### 4. KMS
O KMS é o Key Management Service, que é o serviço de gerenciamento de chaves. Para isso, é necessário criar uma chave e definir as regras de acesso.
- Criacao da chave: ```main.tf``` linhas 78-80 (nome = "example", essa chave será usada para criptografar o secret que sao armazenados no secret manager)
- Criacao do segredo: ```main.tf``` linhas 82-86 (nome = "example-16-pwetty-please", kms_ket_id indica qual chave será usada para criptografar o secret)
-Criacao de um exemplo de segredo: ```main.tf``` linhas 88-92 (secret_string indica o conteúdo do secret que esta dentro de um arquivo chamado "secrets.json")
- Politica de acesso: ```main.tf``` linhas 94-112 (essa politica permite o principal (no caso, a funcao IAM com ARN especifico) a acessar a chave criada anteriormente)

