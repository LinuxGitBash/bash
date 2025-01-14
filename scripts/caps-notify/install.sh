#!/bin/bash

INSTALL_DIR="$1"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Установка зависимостей
if command -v apt &> /dev/null; then
    apt install -y libnotify-bin x11-xserver-utils
elif command -v dnf &> /dev/null; then
    dnf install -y libnotify xorg-x11-server-utils
elif command -v pacman &> /dev/null; then
    pacman -S --noconfirm libnotify xorg-xset
fi

# Копирование и настройка прав
cp "$SCRIPT_DIR/caps_notify.sh" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/caps_notify.sh"

# Создание systemd сервиса
cat > /etc/systemd/system/caps-notify.service << EOL
[Unit]
Description=Caps Lock Notification Service
After=graphical-session.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/caps_notify.sh
Restart=always
RestartSec=1
User=$SUDO_USER

[Install]
WantedBy=multi-user.target
EOL

# Активация сервиса
systemctl daemon-reload
systemctl enable caps-notify.service
systemctl start caps-notify.service 