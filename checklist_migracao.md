# Guia de Migração VPS (n8n, Evolution API, Redis, Banco de Dados)

Este guia descreve o processo de migração de sua stack EasyPanel da VPS antiga para a nova, utilizando o Git como facilitador para scripts e configurações, e transferência de arquivos para os dados.

## Visão Geral

1.  **Mapear Configuração**: Como o Coolify usa uma estrutura diferente, vamos criar um `docker-compose.yml` que represente seus serviços.
2.  **Backup de Dados (Script)**: Gerar dumps dos bancos de dados e copiar arquivos de volume importantes (Procedimento igual).
3.  **Repositório Git**: Versionar o `docker-compose.yml` e scripts.
4.  **Nova VPS (Coolify)**: Importar o projeto via Docker Compose (Git ou File).
5.  **Restaurar Dados**: Reaplicar os backups nos volumes criados pelo Coolify.

## Passo 1: Criar o Docker Compose (Migração para Coolify)

O EasyPanel exporta um JSON proprietário, mas o Coolify adora **Docker Compose**.
Crie um arquivo `docker-compose.yml` neste repositório. Ele deve conter seus serviços:
- Postgres (Banco)
- Redis
- n8n
- Evolution API

> **Dica**: No Coolify, você pode simplesmente conectar este repositório Git. O Coolify vai ler o `docker-compose.yml` e subir tudo automaticamente.

## Passo 2: Backup dos Dados (VPS Antiga - EasyPanel)

Utilize o script `backup_data.sh` incluído neste repositório.
Este script deve ser ajustado para os nomes dos seus containers.

> **Atenção**: O Git não é ideal para arquivos gigantes (GBs). Se seus backups forem pequenos (<100MB), pode usar o Git. Se forem grandes, use `scp` ou transfira via nuvem (S3/Drive).

## Passo 3: Configurar a Nova VPS (Coolify)

1.  Acesse seu Coolify.
2.  Crie um novo **Project** -> **Environment**.
3.  Escolha **Resource** -> **Docker Compose**.
4.  Você pode colar o conteúdo do `docker-compose.yml` que criamos ou conectar este repositório do Git.
5.  **Variáveis de Ambiente**: Antes de iniciar (deploy), vá em cada serviço no Coolify e adicione as variáveis críticas, principalmente `N8N_ENCRYPTION_KEY` que deve ser IGUAL à antiga.

## Passo 4: Restaurar Dados (Executar na Nova VPS)

1.  No Coolify, depois do primeiro deploy (mesmo que vazio), ele cria os containers.
2.  Descubra os nomes dos containers ou IDs rodando `docker ps` no terminal da nova VPS.
3.  Clone este repositório na nova VPS (ou apenas copie o script e o backup).
4.  Edite o `restore_data.sh` para usar os **novos nomes** de container do Coolify (geralmente algo como `uuid-postgres`).
5.  Execute o script `restore_data.sh`.
6.  Reinicie os serviços no painel do Coolify (Redeploy).

## Detalhes Específicos por Serviço

### n8n
- **Dados**: Geralmente ficam em `/home/node/.n8n`.
- **Banco**: Se usa SQLite, é um arquivo. Se usa Postgres, precisa do dump.
- **Encryption Key**: SALVE A VARIÁVEL DE AMBIENTE `N8N_ENCRYPTION_KEY`. Sem ela, suas credenciais não funcionarão na nova VPS.

### Evolution API
- **Sessões**: Estão na pasta `instances` ou no Redis. É recomendável refazer a conexão do QR Code se a migração de sessão falhar, mas copiar a pasta pode funcionar.
- **Banco**: Geralmente Postgres ou MongoDB. Requer dump.

### Redis
- Geralmente é cache. Se perder, não é crítico, mas se usar para filas importantes, faça o dump do `dump.rdb`.
