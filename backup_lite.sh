#!/bin/bash
# Script de Backup "Lite" - Apenas Arquivos (n8n + Evolution)
# Ignora o dump do banco de dados pesado.

# Nomes EXATOS da sua VPS Antiga (EasyPanel)
CONTAINER_N8N="automacao_n8n.1.yl2tyc3pxz5h4no2f2b9x79j9"
CONTAINER_EVOLUTION="automacao_evolution.1.oas74y5iyqkby2sjncg5puxjo"

mkdir -p ./backups_lite

echo "--- Iniciando Backup Lite (Apenas Configs) ---"

# 1. n8n
echo "1. Copiando arquivos do n8n..."
if docker ps | grep -q $CONTAINER_N8N; then
    docker cp $CONTAINER_N8N:/home/node/.n8n ./backups_lite/n8n_data
    echo "   -> n8n copiada."
else
    echo "   [!] Container n8n não encontrado ($CONTAINER_N8N)"
fi

# 2. Evolution
echo "2. Copiando instâncias da Evolution API..."
if docker ps | grep -q $CONTAINER_EVOLUTION; then
    docker cp $CONTAINER_EVOLUTION:/evolution/instances ./backups_lite/evolution_instances
    echo "   -> Evolution copiada."
else
    echo "   [!] Container Evolution não encontrado ($CONTAINER_EVOLUTION)"
fi

# 3. Compactar
echo "3. Compactando..."
tar -czvf backup_lite.tar.gz ./backups_lite

echo "--- Pronto! ---"
echo "Baixe o arquivo 'backup_lite.tar.gz'."
