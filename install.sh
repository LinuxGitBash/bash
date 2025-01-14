#!/bin/bash

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

# Проверяем наличие zenity
if ! command -v zenity &> /dev/null; then
    echo "Установка zenity..."
    if command -v apt &> /dev/null; then
        sudo apt install -y zenity
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y zenity
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm zenity
    else
        echo "Не удалось установить zenity. Установите вручную."
        exit 1
    fi
fi

# Цвета для вывода в терминал
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Функция для отображения прогресса
show_progress() {
    echo "$1" | zenity --progress --pulsate --title="Установка скриптов" --text="$1" --auto-close --width=300
}

# Приветственное окно
zenity --info \
    --title="Установщик Bash Scripts" \
    --text="Добро пожаловать в установщик Bash Scripts Collection!" \
    --width=300

# URL репозитория по умолчанию
DEFAULT_REPO="https://github.com/LinuxGitBash/bash"

# Спрашиваем, хочет ли пользователь использовать другой репозиторий
if zenity --question \
    --title="Выбор репозитория" \
    --text="Использовать репозиторий по умолчанию ($DEFAULT_REPO)?" \
    --width=300; then
    REPO_URL="$DEFAULT_REPO"
else
    REPO_URL=$(zenity --entry \
        --title="Установка" \
        --text="Введите URL GitHub репозитория:" \
        --entry-text="$DEFAULT_REPO" \
        --width=300) || exit 1
fi

# Выбираем директорию установки
INSTALL_DIR=$(zenity --file-selection \
    --title="Выберите директорию для установки" \
    --directory \
    --filename="$HOME/.local/bin") || exit 1

# Клонируем репозиторий во временную директорию
TEMP_DIR=$(mktemp -d)
if ! git clone "$REPO_URL" "$TEMP_DIR" 2>&1 | show_progress "Загрузка репозитория..."; then
    zenity --error \
        --title="Ошибка" \
        --text="Не удалось загрузить репозиторий. Проверьте URL и подключение к интернету." \
        --width=300
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Создаем директорию для установки если она не существует
mkdir -p "$INSTALL_DIR"

# Копируем скрипты
(
echo "10"; echo "# Подготовка к установке..."
sleep 1

echo "30"; echo "# Копирование скриптов..."
if [ -d "$TEMP_DIR/scripts" ]; then
    find "$TEMP_DIR/scripts" -type f -name "*.sh" -exec cp {} "$INSTALL_DIR/" \;
else
    # Если директории scripts нет, копируем все .sh файлы из корня
    cp "$TEMP_DIR"/*.sh "$INSTALL_DIR/" 2>/dev/null
fi

echo "50"; echo "# Установка прав доступа..."
chmod +x "$INSTALL_DIR"/*.sh 2>/dev/null

echo "70"; echo "# Настройка PATH..."
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo 'export PATH="$PATH:'"$INSTALL_DIR"'"' >> "$HOME/.bashrc"
fi

echo "90"; echo "# Очистка временных файлов..."
rm -rf "$TEMP_DIR"

echo "100"; echo "# Установка завершена!"
) | zenity --progress \
    --title="Установка" \
    --text="Начало установки..." \
    --percentage=0 \
    --auto-close \
    --width=300

if [ $? = 0 ]; then
    zenity --info \
        --title="Успех" \
        --text="Установка успешно завершена!\n\nПожалуйста, перезапустите терминал или выполните:\nsource ~/.bashrc" \
        --width=300
else
    zenity --error \
        --title="Ошибка" \
        --text="Произошла ошибка при установке." \
        --width=300
fi