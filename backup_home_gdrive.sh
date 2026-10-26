#!/bin/bash

# Captura o nome da distro do os-release (ex: Arch Linux vira Arch_Linux, ou usa "Linux" se falhar)
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_NOME="${NAME// /_}"
else
    DISTRO_NOME="Linux"
fi

# Configurações
DATA=$(date +%Y-%m-%d_%H-%M-%S)
ARQUIVO="home_${DISTRO_NOME}_backup_$DATA.tar.gz"
DESTINO_LOCAL="/tmp/$ARQUIVO"
REMOTE_GDRIVE="gdrive:Backup ThinkPad RClone"

# Executa o backup compactado da pasta home em /tmp
tar -czpf "$DESTINO_LOCAL" /home

# Envia o arquivo compactado para a pasta na raiz do Google Drive
rclone copy "$DESTINO_LOCAL" "$REMOTE_GDRIVE" --progress

# Remove o arquivo temporário local após o envio
rm -f "$DESTINO_LOCAL"

# Remove backups antigos na nuvem com mais de 30 dias (opcional)
rclone delete "$REMOTE_GDRIVE" --min-age 30d --include "home_${DISTRO_NOME}_backup_*.tar.gz"

echo "Backup da distribuição $NAME enviado para o Google Drive com sucesso: $ARQUIVO"
