#!/bin/bash

INSTALL_DIR="$1"
CURRENT_USER=$SUDO_USER

# Установка зависимостей
if command -v apt &> /dev/null; then
    apt install -y libnotify-bin xbindkeys feh
elif command -v dnf &> /dev/null; then
    dnf install -y libnotify xbindkeys feh
elif command -v pacman &> /dev/null; then
    pacman -S --noconfirm libnotify xbindkeys feh
fi

# Копирование и настройка прав
cp wallpaper_switcher.sh "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/wallpaper_switcher.sh"

# Создаем автозапуск для биндинга клавиш
mkdir -p /home/$CURRENT_USER/.config/autostart
cat > /home/$CURRENT_USER/.config/autostart/wallpaper-switcher.desktop << EOL
[Desktop Entry]
Type=Application
Name=Wallpaper Switcher
Comment=Hotkey binding for wallpaper switching
Exec=$INSTALL_DIR/wallpaper_switcher.sh
Hidden=false
X-GNOME-Autostart-enabled=true
EOL

# Устанавливаем правильные права
chown -R $CURRENT_USER:$CURRENT_USER /home/$CURRENT_USER/.config/autostart

# Запускаем для текущего пользователя
sudo -u $CURRENT_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $CURRENT_USER)/bus" $INSTALL_DIR/wallpaper_switcher.sh 