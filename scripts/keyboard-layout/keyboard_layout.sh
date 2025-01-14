#!/bin/bash

# Настраиваем переключение раскладки на Alt+Shift
setxkbmap -layout us,ru -option grp:alt_shift_toggle

# Добавляем настройку для индикатора раскладки
gsettings set org.gnome.desktop.input-sources show-all-sources true

# Показываем уведомление
notify-send "Раскладка клавиатуры" "Настроено переключение Alt+Shift\nUS ⟷ RU" -i keyboard

# Запускаем индикатор раскладки (если есть)
if command -v gxkb &> /dev/null; then
    gxkb &
fi 