#!/bin/bash

# Настройка переменных окружения
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# Настраиваем раскладку
setxkbmap -layout us,ru -option grp:alt_shift_toggle

# Запускаем индикатор без терминала
if command -v gxkb &> /dev/null; then
    nohup gxkb >/dev/null 2>&1 &
fi

# Уведомление
notify-send "Раскладка клавиатуры" "✓ Переключение Alt+Shift активировано\nUS ⟷ RU" -i keyboard 