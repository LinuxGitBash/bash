#!/bin/bash

# Проверяем наличие xdotool
if ! command -v xdotool &> /dev/null; then
    if command -v zenity &> /dev/null; then
        zenity --error \
            --title="Ошибка" \
            --text="Требуется установить xdotool.\nУстановите командой:\nsudo apt install xdotool" \
            --width=300
    else
        echo "Ошибка: требуется установить xdotool"
        echo "Установите командой: sudo apt install xdotool"
    fi
    exit 1
fi

# Настраиваем переключение раскладки на Alt+Shift
setxkbmap -layout us,ru -option grp:alt_shift_toggle

# Функция для отображения уведомления
show_notification() {
    local message="$1"
    
    if command -v notify-send &> /dev/null; then
        notify-send "Раскладка" "$message" -i keyboard
    elif command -v zenity &> /dev/null; then
        zenity --notification --text="Раскладка: $message"
    else
        echo "Раскладка: $message"
    fi
}

# Получаем текущую раскладку
current_layout=$(setxkbmap -query | grep layout | awk '{print $2}')

# Показываем уведомление о текущей раскладке
if [[ $current_layout == *"ru"* ]]; then
    show_notification "Текущая раскладка: RU"
else
    show_notification "Текущая раскладка: US"
fi 