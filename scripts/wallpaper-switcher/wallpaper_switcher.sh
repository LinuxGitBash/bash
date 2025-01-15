#!/bin/bash

# Настройка переменных окружения
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# Директории с обоями
WALLPAPERS_DIRS=(
    "$HOME/Pictures/Wallpapers"                  # Пользовательские обои
    "/usr/share/backgrounds"                     # Системные обои
    "/usr/share/wallpapers"                      # KDE обои
    "/usr/share/gnome-background-properties"     # GNOME обои
)

# Функция для получения случайного обоя
get_random_wallpaper() {
    local wallpapers=()
    
    # Собираем все обои из всех директорий
    for dir in "${WALLPAPERS_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            while IFS= read -r -d '' file; do
                wallpapers+=("$file")
            done < <(find "$dir" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) -print0)
        fi
    done
    
    # Если есть обои, выбираем случайный
    if [ ${#wallpapers[@]} -gt 0 ]; then
        echo "${wallpapers[RANDOM % ${#wallpapers[@]}]}"
    fi
}

# Функция для смены обоев
change_wallpaper() {
    # Получаем случайный файл
    WALLPAPER=$(get_random_wallpaper)
    
    if [ -n "$WALLPAPER" ]; then
        # Меняем обои в зависимости от DE
        if command -v gsettings &> /dev/null; then
            # GNOME/Unity
            gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
            gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"
        elif command -v xfconf-query &> /dev/null; then
            # XFCE
            xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "$WALLPAPER"
        elif command -v plasma-apply-wallpaperimage &> /dev/null; then
            # KDE
            plasma-apply-wallpaperimage "$WALLPAPER"
        else
            # Fallback using feh
            feh --bg-fill "$WALLPAPER"
        fi
        
        # Показываем уведомление с именем файла
        filename=$(basename "$WALLPAPER")
        notify-send "Обои рабочего стола" "✓ Установлены обои:\n$filename" -i preferences-desktop-wallpaper
    else
        notify-send "Обои рабочего стола" "❌ Не найдены доступные обои" -i dialog-error
    fi
}

# Создаем пользовательскую директорию если её нет
mkdir -p "$HOME/Pictures/Wallpapers"

# Настраиваем горячую клавишу
if command -v xbindkeys &> /dev/null; then
    # Создаем конфиг для xbindkeys
    mkdir -p "$HOME/.config"
    cat > "$HOME/.xbindkeysrc" << EOL
"$INSTALL_DIR/wallpaper_switcher.sh --change"
    Control + w
EOL
    
    # Перезапускаем xbindkeys
    killall xbindkeys 2>/dev/null
    xbindkeys
fi

# Проверяем аргументы
if [ "$1" = "--change" ]; then
    change_wallpaper
fi 