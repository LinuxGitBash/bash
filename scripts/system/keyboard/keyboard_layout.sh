#!/bin/bash

# Проверяем наличие xdotool
if ! command -v xdotool &> /dev/null; then
    zenity --error \
        --title="Ошибка" \
        --text="Требуется установить xdotool.\nУстановите командой:\nsudo apt install xdotool" \
        --width=300
    exit 1
fi

# Получаем текущую раскладку
current_layout=$(setxkbmap -query | grep layout | awk '{print $2}')

# Переключаем раскладку
if [ "$current_layout" = "us" ]; then
    setxkbmap ru
    notify-send "Раскладка" "Переключено на RU" -i keyboard
else
    setxkbmap us
    notify-send "Раскладка" "Переключено на US" -i keyboard
fi

# Симулируем нажатие Alt для сброса залипших клавиш
xdotool key Alt_L 