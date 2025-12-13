# Guia de Migração VPS (n8n, Evolution API, Redis, Banco de Dados)

Este guia descreve o processo de migração de sua stack EasyPanel da VPS antiga para a nova, utilizando o Git como facilitador para scripts e configurações, e transferência de arquivos para os dados.

## Visão Geral

1.  **Exportar Configuração**: Salvar a estrutura do projeto do EasyPanel (JSON).
2.  **Backup de Dados (Script)**: Gerar dumps dos bancos de dados e copiar arquivos de volume importantes.
3.  **Repositório Git**: Versionar os scripts e configurações.
4.  **Nova VPS**: Preparar o ambiente e importar configurações.
5.  **Restaurar Dados (Script)**: Reaplicar os backups na nova infraestrutura.

## Passo 1: Exportar Configuração do EasyPanel

1.  Acesse o painel do **EasyPanel** na VPS antiga.
2.  Vá até o **Projeto** que contém seus serviços.
3.  Procure a opção de **Settings** (Configurações) do projeto.
4.  Clique em **Export Project** (ou copie o JSON de configuração).
5.  Salve este conteúdo num arquivo chamado `easypanel-project.json` na pasta deste repositório.

## Passo 2: Backup dos Dados (Executar na VPS Antiga)

Utilize o script `backup_data.sh` incluído neste repositório.
Este script deve ser ajustado para os nomes dos seus containers.

> **Atenção**: O Git não é ideal para arquivos gigantes (GBs). Se seus backups forem pequenos (<100MB), pode usar o Git. Se forem grandes, use `scp` ou transfira via nuvem (S3/Drive).

## Passo 3: Configurar a Nova VPS

1.  Instale o Docker e o EasyPanel na nova VPS.
2.  Crie um projeto vazio.
3.  Utilize a opção **Import** e use o arquivo `easypanel-project.json` (ou configure manualmente baseado nele).
4.  **Importante**: Não inicie os serviços ainda, ou pare-os logo após o deploy inicial para restaurar os dados.

## Passo 4: Restaurar Dados (Executar na Nova VPS)

1.  Clone este repositório na nova VPS.
2.  Coloque os arquivos de backup gerados (`dump.sql`, `volumes.tar.gz`) na pasta `backups/`.
3.  Execute o script `restore_data.sh`.
4.  Reinicie os containers no EasyPanel.

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
