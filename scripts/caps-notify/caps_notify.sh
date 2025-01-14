#!/bin/bash

# Проверяем наличие xset
if ! command -v xset &> /dev/null; then
    echo "Ошибка: требуется xset"
    exit 1
fi

# Функция для отображения уведомления
show_notification() {
    local state="$1"
    local icon="$2"
    
    if command -v notify-send &> /dev/null; then
        sudo -u $SUDO_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u $SUDO_USER)/bus notify-send "Caps Lock" "$state" -i "$icon" -t 1000
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