#!/bin/bash

# Настройка переменных окружения
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# Функция для уведомлений
show_notification() {
    notify-send "Caps Lock" "$1" -i keyboard -t 1000
}

# Проверка состояния
check_caps_state() {
    xset q | grep "Caps Lock" | awk '{print $4}'
}

# Запуск в фоне
(
    previous_state=""
    while true; do
        current_state=$(check_caps_state)
        if [ "$current_state" != "$previous_state" ]; then
            if [ "$current_state" = "on" ]; then
                show_notification "ВКЛЮЧЕН"
            else
                show_notification "выключен"
            fi
            previous_state="$current_state"
        fi
        sleep 1
    done
) >/dev/null 2>&1 &

# Уведомление о запуске
notify-send "Caps Lock Notify" "✓ Сервис активирован" -i keyboard 