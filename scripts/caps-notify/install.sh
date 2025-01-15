#!/bin/bash

INSTALL_DIR="$1"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
CURRENT_USER=$SUDO_USER

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

# Создаем автозапуск для текущего пользователя
mkdir -p /home/$CURRENT_USER/.config/autostart
cat > /home/$CURRENT_USER/.config/autostart/caps-notify.desktop << EOL
[Desktop Entry]
Type=Application
Name=Caps Lock Notification
Comment=Shows notification when Caps Lock state changes
Exec=$INSTALL_DIR/caps_notify.sh
Hidden=false
X-GNOME-Autostart-enabled=true
EOL

# Устанавливаем правильные права
chown -R $CURRENT_USER:$CURRENT_USER /home/$CURRENT_USER/.config/autostart

# Запускаем сервис для текущего пользователя
sudo -u $CURRENT_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $CURRENT_USER)/bus" $INSTALL_DIR/caps_notify.sh 