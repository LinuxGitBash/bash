#!/bin/bash

# Проверяем наличие xset
if ! command -v xset &> /dev/null; then
    if command -v zenity &> /dev/null; then
        zenity --error \
            --title="Ошибка" \
            --text="Требуется установить xset.\nУстановите командой:\nsudo apt install x11-xserver-utils" \
            --width=300
    else
        echo "Ошибка: требуется установить xset"
        echo "Установите командой: sudo apt install x11-xserver-utils"
    fi
    exit 1
fi

# Функция для отображения уведомления
show_notification() {
    local state="$1"
    local icon="$2"
    
    if command -v notify-send &> /dev/null && notify-send --version &> /dev/null; then
        notify-send "Caps Lock" "$state" -i "$icon" -t 1000
    elif command -v zenity &> /dev/null; then
        zenity --notification --text="Caps Lock: $state"
    else
        echo "Caps Lock: $state"
    fi
}

# Функция для проверки состояния Caps Lock
check_caps_state() {
    xset q | grep "Caps Lock" | awk '{print $4}'
}

# Бесконечный цикл проверки состояния
previous_state=""
while true; do
    current_state=$(check_caps_state)
    
    if [ "$current_state" != "$previous_state" ]; then
        if [ "$current_state" = "on" ]; then
            show_notification "ВКЛЮЧЕН" "capslock-on"
        else
            show_notification "выключен" "capslock-off"
        fi
        previous_state="$current_state"
    fi
    
    sleep 0.5
done 