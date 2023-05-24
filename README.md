# Projeto Cloud
**Desenvolvido por:** Ricardo Israel

## Como rodar o projeto
No arquivo ```main.tf```, é necessário trocar o nome do *secret manager* (linha 84) para um nome que náo existe ainda. O nome pode ser o que vocë quiser, mas como sugestáo, use o nome:
- "example-17-pwetty-please", aumentando uma unidade no número a cada novo teste.

A seguir, os 3 principais comandos do terraform para subir a aplicação:
- ```terraform init```
- ```terraform plan```
- ```terraform apply``` (náo se esqueça de escrever "yes" na hora de digitar um valor)

Após o apply, haverá um link como output, e será gerado no próprio terminal.

Copie esse link e cole em uma nova aba.

Haverá um "Hello, World!" na tela. Isso significa que você conseguiu acesso ao secret, e consequentemente a aplicação. 


