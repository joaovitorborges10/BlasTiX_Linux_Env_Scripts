# 1. Copiar a configuração do rclone para o diretório do root (caso ainda não esteja lá)
sudo mkdir -p /root/.config/rclone
sudo cp ~/.config/rclone/rclone.conf /root/.config/rclone/rclone.conf

# 2. Recriar o arquivo de script com as correções completas
sudo tee /usr/local/bin/backup_home_gdrive.sh << 'EOF' > /dev/null
#!/bin/bash

# Garante que a configuração do rclone existe no diretório do root
if [ ! -f /root/.config/rclone/rclone.conf ] && [ -f /home/joao/.config/rclone/rclone.conf ]; then
    mkdir -p /root/.config/rclone
    cp /home/joao/.config/rclone/rclone.conf /root/.config/rclone/rclone.conf
fi

# Captura o nome da distro do os-release
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

# Executa o backup compactado da pasta home em /tmp (ignorando erros de leitura de arquivos em uso)
tar --ignore-failed-read -czpf "$DESTINO_LOCAL" /home

# Envia o arquivo compactado para a pasta na raiz do Google Drive
rclone copy "$DESTINO_LOCAL" "$REMOTE_GDRIVE" --progress

# Remove o arquivo temporário local após o envio
rm -f "$DESTINO_LOCAL"

# Remove backups antigos na nuvem com mais de 30 dias
rclone delete "$REMOTE_GDRIVE" --min-age 30d --include "home_${DISTRO_NOME}_backup_*.tar.gz"

echo "Backup da distribuição $NAME enviado para o Google Drive com sucesso: $ARQUIVO"
EOF

# 3. Dar permissão de execução
sudo chmod +x /usr/local/bin/backup_home_gdrive.sh