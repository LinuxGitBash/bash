#!/bin/bash

INSTALL_DIR="$1"

# Проверяем и устанавливаем зависимости
if ! command -v notify-send &> /dev/null; then
    echo "Установка libnotify-bin..."
    if command -v apt &> /dev/null; then
        sudo apt install -y libnotify-bin
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y libnotify
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm libnotify
    fi
fi

if ! command -v xset &> /dev/null; then
    echo "Установка x11-xserver-utils..."
    if command -v apt &> /dev/null; then
        sudo apt install -y x11-xserver-utils
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y xorg-x11-server-utils
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm xorg-xset
    fi
fi

# Копируем скрипт
cp caps_notify.sh "$INSTALL_DIR/"
cp stop.sh "$INSTALL_DIR/caps_notify_stop.sh"
chmod +x "$INSTALL_DIR/caps_notify.sh"
chmod +x "$INSTALL_DIR/caps_notify_stop.sh"

# Создаем автозапуск
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/caps-notify.desktop" << EOL
[Desktop Entry]
Type=Application
Name=Caps Lock Notification
Comment=Shows notification when Caps Lock state changes
Exec=$INSTALL_DIR/caps_notify.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOL

# Запускаем скрипт
nohup "$INSTALL_DIR/caps_notify.sh" >/dev/null 2>&1 &

# Настраиваем PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo 'export PATH="$PATH:'"$INSTALL_DIR"'"' >> "$HOME/.bashrc"
fi 