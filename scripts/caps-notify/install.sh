#!/bin/bash

# Проверяем root права
if [ "$EUID" -ne 0 ]; then
    echo "Требуются права root"
    exit 1
fi

# Проверяем путь установки
if [ -z "$1" ]; then
    echo "Ошибка: не указан путь установки"
    exit 1
fi

INSTALL_DIR="$1"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Устанавливаем зависимости
echo "Установка зависимостей..."
if command -v apt &> /dev/null; then
    apt install -y libnotify-bin x11-xserver-utils
elif command -v dnf &> /dev/null; then
    dnf install -y libnotify xorg-x11-server-utils
elif command -v pacman &> /dev/null; then
    pacman -S --noconfirm libnotify xorg-xset
fi

# Создаем директорию установки
mkdir -p "$INSTALL_DIR"

# Копируем скрипты
echo "Копирование скриптов..."
cp "$SCRIPT_DIR/caps_notify.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/stop.sh" "$INSTALL_DIR/caps_notify_stop.sh"
chmod +x "$INSTALL_DIR/caps_notify.sh"
chmod +x "$INSTALL_DIR/caps_notify_stop.sh"

# Создаем systemd сервис
echo "Настройка systemd сервиса..."
SYSTEMD_DIR="/etc/systemd/system"
cat > "$SYSTEMD_DIR/caps-notify.service" << EOL
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

# Настраиваем systemd
systemctl daemon-reload
systemctl enable caps-notify.service
systemctl start caps-notify.service

# Добавляем в PATH для всех пользователей
echo "PATH=\$PATH:$INSTALL_DIR" > /etc/profile.d/caps-notify.sh
chmod +x /etc/profile.d/caps-notify.sh

echo "Установка caps-notify завершена успешно" 