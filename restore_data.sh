#!/bin/bash
# Script de Restauração para Nova VPS
# Execute este script via SSH na nova VPS

# Configurações (AJUSTE CONFORME SEUS NOVOS NOMES DE CONTAINER)
CONTAINER_DB="nome_do_novo_container_postgres"
CONTAINER_N8N="nome_do_novo_container_n8n"
CONTAINER_EVOLUTION="nome_do_novo_container_evolution"
DB_USER="seu_usuario_banco"
DB_NAME="seu_nome_banco"

# Verificar se o arquivo existe
if [ ! -f "backup_completo.tar.gz" ]; then
    echo "Arquivo backup_completo.tar.gz não encontrado!"
    exit 1
fi

echo "--- Iniciando Restauração ---"

# 1. Descompactar
tar -xzvf backup_completo.tar.gz

# 2. Restaurar Banco
echo "2. Restaurando Banco de Dados..."
# Pode ser necessário dropar o banco vazio criado pelo EasyPanel antes, ou apenas rodar o psql
if docker ps | grep -q $CONTAINER_DB; then
    cat ./backups/database_dump.sql | docker exec -i $CONTAINER_DB psql -U $DB_USER -d $DB_NAME
    echo "   -> Banco restaurado."
else
    echo "   [!] Container do Banco não encontrado."
fi

# 3. Restaurar Arquivos n8n
echo "3. Restaurando arquivos n8n..."
if docker ps | grep -q $CONTAINER_N8N; then
    docker cp ./backups/n8n_data/. $CONTAINER_N8N:/home/node/.n8n
    # Ajustar permissões é crucial
    docker exec -u root $CONTAINER_N8N chown -R node:node /home/node/.n8n
    echo "   -> Arquivos n8n copiados."
fi

# 4. Restaurar Evolution
echo "4. Restaurando Evolution API..."
if docker ps | grep -q $CONTAINER_EVOLUTION; then
    docker cp ./backups/evolution_instances/. $CONTAINER_EVOLUTION:/evolution/instances
    echo "   -> Instâncias copiadas."
fi

echo "--- Restauração Finalizada ---"
echo "Reinicie os containers pelo EasyPanel para garantir que carreguem os novos dados."
