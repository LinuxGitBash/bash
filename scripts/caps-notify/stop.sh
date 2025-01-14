#!/bin/bash

# Находим PID процесса
PID=$(pgrep -f "caps_notify.sh")

if [ -n "$PID" ]; then
    # Завершаем процесс
    kill $PID
    
    # Показываем уведомление
    if command -v notify-send &> /dev/null; then
        notify-send "Caps Lock Notify" "Сервис остановлен" -i system-shutdown
    elif command -v zenity &> /dev/null; then
        zenity --notification --text="Caps Lock Notify: сервис остановлен"
    else
        echo "Caps Lock Notify: сервис остановлен"
    fi
else
    if command -v zenity &> /dev/null; then
        zenity --error \
            --title="Ошибка" \
            --text="Сервис Caps Lock Notify не запущен" \
            --width=300
    else
        echo "Сервис Caps Lock Notify не запущен"
    fi
fi 