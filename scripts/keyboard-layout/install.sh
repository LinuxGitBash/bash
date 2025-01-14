#!/bin/bash

INSTALL_DIR="$1"

# Проверяем и устанавливаем зависимости
if ! command -v notify-send &> /dev/null; then
    echo "Установка libnotify-bin..."
    if command -v apt &> /dev/null; then
        sudo apt install -y libnotify-bin
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y libnotify
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm libnotify
    fi
fi

if ! command -v xdotool &> /dev/null; then
    echo "Установка xdotool..."
    if command -v apt &> /dev/null; then
        sudo apt install -y xdotool
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y xdotool
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm xdotool
    fi
fi

# Копируем скрипт
cp keyboard_layout.sh "$INSTALL_DIR/"
cp stop.sh "$INSTALL_DIR/keyboard_layout_stop.sh"
chmod +x "$INSTALL_DIR/keyboard_layout.sh"
chmod +x "$INSTALL_DIR/keyboard_layout_stop.sh"

# Настраиваем PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo 'export PATH="$PATH:'"$INSTALL_DIR"'"' >> "$HOME/.bashrc"
fi 