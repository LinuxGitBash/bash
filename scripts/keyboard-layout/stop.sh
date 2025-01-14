#!/bin/bash

# Сбрасываем настройки клавиатуры
setxkbmap -layout us -option ''

# Показываем уведомление
if command -v notify-send &> /dev/null; then
    notify-send "Keyboard Layout" "Настройки раскладки сброшены" -i keyboard
elif command -v zenity &> /dev/null; then
    zenity --notification --text="Keyboard Layout: настройки раскладки сброшены"
else
    echo "Keyboard Layout: настройки раскладки сброшены"
fi 