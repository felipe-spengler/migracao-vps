#!/bin/bash
# Script de Backup para VPS Antiga
# Execute este script via SSH na sua VPS antiga

# Configurações (AJUSTE CONFORME SEUS NOMES DE CONTAINER)
# No EasyPanel, geralmente é: projeto-servico-1
# Baseado no seu projeto 'automacao', os prováveis nomes são:
CONTAINER_DB="automacao-evolution-db-1"       # Ou apenas 'automacao-postgres-1', verifique com 'docker ps'
CONTAINER_N8N="automacao-n8n-1"
CONTAINER_EVOLUTION="automacao-evolution-1"
DB_USER="postgres"
DB_NAME="automacao"

# Criar pasta de backup
mkdir -p ./backups

echo "--- Iniciando Backup ---"

# 1. Backup do Banco de Dados (Exemplo Postgres)
echo "1. Dump do Banco de Dados..."
if docker ps | grep -q $CONTAINER_DB; then
    docker exec -t $CONTAINER_DB pg_dump -U $DB_USER $DB_NAME > ./backups/database_dump.sql
    echo "   -> Banco dumpado com sucesso."
else
    echo "   [!] Container do Banco não encontrado ou nome incorreto."
fi

# 2. Backup de Arquivos do n8n (Necessário parar para garantir integridade se for SQLite)
# Se usar Postgres para o n8n, o passo 1 já cobre os dados principais.
# Mas precisamos da chave de criptografia e talvez arquivos binários.
echo "2. Copiando arquivos do n8n..."
# Copia a pasta de dados inteira (pode demorar)
docker cp $CONTAINER_N8N:/home/node/.n8n ./backups/n8n_data

# 3. Backup Evolution API (Instâncias/Sessions)
echo "3. Copiando instâncias da Evolution API..."
docker cp $CONTAINER_EVOLUTION:/evolution/instances ./backups/evolution_instances
# Ajuste o caminho '/evolution/instances' conforme o volume mapeado no seu container

# 4. Compactar tudo
echo "4. Compactando backups..."
tar -czvf backup_completo.tar.gz ./backups

echo "--- Backup Finalizado ---"
echo "O arquivo 'backup_completo.tar.gz' está pronto."
echo "Transfira este arquivo para a nova VPS ou comite no Git (se for pequeno)."
