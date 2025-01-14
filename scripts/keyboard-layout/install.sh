#!/bin/bash

INSTALL_DIR="$1"
CURRENT_USER=$SUDO_USER

# Установка зависимостей
export DEBIAN_FRONTEND=noninteractive
if command -v apt &> /dev/null; then
    apt install -y libnotify-bin xdotool gxkb
elif command -v dnf &> /dev/null; then
    dnf install -y libnotify xdotool gxkb
elif command -v pacman &> /dev/null; then
    pacman -S --noconfirm libnotify xdotool gxkb
fi

# Копирование и настройка прав
cp keyboard_layout.sh "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/keyboard_layout.sh"

# Автозапуск
mkdir -p /home/$CURRENT_USER/.config/autostart
cat > /home/$CURRENT_USER/.config/autostart/keyboard-layout.desktop << EOL
[Desktop Entry]
Type=Application
Name=Keyboard Layout Switcher
Exec=$INSTALL_DIR/keyboard_layout.sh
Hidden=false
X-GNOME-Autostart-enabled=true
EOL

chown -R $CURRENT_USER:$CURRENT_USER /home/$CURRENT_USER/.config/autostart

# Запуск
sudo -u $CURRENT_USER $INSTALL_DIR/keyboard_layout.sh 