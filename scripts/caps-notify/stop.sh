#!/bin/bash

# Останавливаем и отключаем сервис
systemctl --user stop caps-notify.service
systemctl --user disable caps-notify.service

# Показываем уведомление
if command -v notify-send &> /dev/null; then
    notify-send "Caps Lock Notify" "Сервис остановлен" -i system-shutdown
elif command -v zenity &> /dev/null; then
    zenity --notification --text="Caps Lock Notify: сервис остановлен"
else
    echo "Caps Lock Notify: сервис остановлен"
fi 