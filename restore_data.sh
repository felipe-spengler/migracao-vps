#!/bin/bash
# Script de Restauração para Nova VPS
# Execute este script via SSH na nova VPS

# Configurações (AJUSTE CONFORME SEUS NOVOS NOMES DE CONTAINER)
CONTAINER_N8N="n8n-l8w8wko08w44wso0sgwsowsg-022131141575"
CONTAINER_EVOLUTION="evolution-api-l8w8wko08w44wso0sgwsowsg-022131150586"
DB_USER="seu_usuario_banco"
DB_NAME="seu_nome_banco"

# Verificar se o arquivo existe (pode ser o completo ou o lite)
if [ -f "backup_completo.tar.gz" ]; then
    tar -xzvf backup_completo.tar.gz
    FOLDER="./backups"
elif [ -f "backup_lite.tar.gz" ]; then
    tar -xzvf backup_lite.tar.gz
    FOLDER="./backups_lite"
else
    echo "Nenhum arquivo de backup (.tar.gz) encontrado!"
    exit 1
fi

echo "--- Iniciando Restauração ---"

# 2. Restaurar Banco (Se houver dump)
if [ -f "$FOLDER/database_dump.sql" ]; then
    echo "2. Restaurando Banco de Dados..."
    if docker ps | grep -q $CONTAINER_DB; then
        cat $FOLDER/database_dump.sql | docker exec -i $CONTAINER_DB psql -U $DB_USER -d $DB_NAME
        echo "   -> Banco restaurado."
    else
        echo "   [!] Container do Banco não encontrado."
    fi
else
    echo "2. Plando restauração de Banco (Arquivo SQL não encontrado no backup Lite)."
fi

# 3. Restaurar Arquivos n8n
echo "3. Restaurando arquivos n8n..."
if docker ps | grep -q $CONTAINER_N8N; then
    docker cp $FOLDER/n8n_data/. $CONTAINER_N8N:/home/node/.n8n
    # Ajustar permissões é crucial
    docker exec -u root $CONTAINER_N8N chown -R node:node /home/node/.n8n
    echo "   -> Arquivos n8n copiados."
fi

# 4. Restaurar Evolution
echo "4. Restaurando Evolution API..."
if docker ps | grep -q $CONTAINER_EVOLUTION; then
    docker cp $FOLDER/evolution_instances/. $CONTAINER_EVOLUTION:/evolution/instances
    echo "   -> Instâncias copiadas."
fi

echo "--- Restauração Finalizada ---"
echo "Reinicie os containers pelo EasyPanel para garantir que carreguem os novos dados."
