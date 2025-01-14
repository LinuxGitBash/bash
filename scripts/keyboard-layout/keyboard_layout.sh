#!/bin/bash

# Проверяем наличие DISPLAY
if [ -z "$DISPLAY" ]; then
    export DISPLAY=:0
fi

# Проверяем наличие DBUS_SESSION_BUS_ADDRESS
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi

# Настраиваем переключение раскладки на Alt+Shift
setxkbmap -layout us,ru -option grp:alt_shift_toggle

# Показываем уведомление
if command -v notify-send &> /dev/null; then
    notify-send "Раскладка клавиатуры" "Настроено переключение Alt+Shift\nUS ⟷ RU" -i keyboard
fi

# Запускаем индикатор раскладки только если есть X11
if [ -n "$DISPLAY" ] && command -v gxkb &> /dev/null; then
    gxkb &
fi 