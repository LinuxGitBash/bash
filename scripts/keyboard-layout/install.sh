#!/bin/bash

INSTALL_DIR="$1"
CURRENT_USER=$SUDO_USER

# Устанавливаем зависимости без интерактивного режима
export DEBIAN_FRONTEND=noninteractive
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

# Добавляем автозапуск для текущего пользователя
mkdir -p /home/$CURRENT_USER/.config/autostart
cat > /home/$CURRENT_USER/.config/autostart/keyboard-layout.desktop << EOL
[Desktop Entry]
Type=Application
Name=Keyboard Layout Switcher
Exec=$INSTALL_DIR/keyboard_layout.sh
Hidden=false
X-GNOME-Autostart-enabled=true
EOL

# Устанавливаем правильные права
chown -R $CURRENT_USER:$CURRENT_USER /home/$CURRENT_USER/.config/autostart

# Применяем настройки для текущего пользователя
sudo -u $CURRENT_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $CURRENT_USER)/bus" $INSTALL_DIR/keyboard_layout.sh 