#!/bin/bash

INSTALL_DIR="$1"

# Устанавливаем зависимости
if command -v apt &> /dev/null; then
    apt install -y libnotify-bin xdotool gxkb
elif command -v dnf &> /dev/null; then
    dnf install -y libnotify xdotool gxkb
elif command -v pacman &> /dev/null; then
    pacman -S --noconfirm libnotify xdotool gxkb
fi

# Копируем скрипты
cp keyboard_layout.sh "$INSTALL_DIR/"
cp stop.sh "$INSTALL_DIR/keyboard_layout_stop.sh"
chmod +x "$INSTALL_DIR/keyboard_layout.sh"
chmod +x "$INSTALL_DIR/keyboard_layout_stop.sh"

# Добавляем автозапуск
mkdir -p /etc/xdg/autostart
cat > /etc/xdg/autostart/keyboard-layout.desktop << EOL
[Desktop Entry]
Type=Application
Name=Keyboard Layout Switcher
Exec=$INSTALL_DIR/keyboard_layout.sh
Hidden=false
X-GNOME-Autostart-enabled=true
EOL

# Применяем настройки
su - $SUDO_USER -c "$INSTALL_DIR/keyboard_layout.sh" 