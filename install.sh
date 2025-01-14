#!/bin/bash

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

# URL репозитория по умолчанию
DEFAULT_REPO="https://github.com/LinuxGitBash/bash"

# Клонируем репозиторий во временную директорию
TEMP_DIR=$(mktemp -d)
if ! git clone "$DEFAULT_REPO" "$TEMP_DIR" 2>/dev/null; then
    zenity --error \
        --title="Ошибка" \
        --text="Не удалось загрузить репозиторий. Проверьте подключение к интернету." \
        --width=300
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Создаем список доступных скриптов
SCRIPTS_LIST=""
for script_dir in "$TEMP_DIR"/scripts/*/; do
    if [ -d "$script_dir" ] && [ -f "$script_dir/install.sh" ]; then
        script_name=$(basename "$script_dir")
        description=$(head -n 1 "$script_dir/README.md" 2>/dev/null || echo "$script_name")
        SCRIPTS_LIST="$SCRIPTS_LIST FALSE \"$script_name\" \"$description\""
    fi
done

# Показываем диалог выбора скриптов
SELECTED_SCRIPTS=$(eval zenity --list \
    --title="Выбор скриптов для установки" \
    --text="Выберите скрипты для установки:" \
    --checklist \
    --column="Выбор" \
    --column="Скрипт" \
    --column="Описание" \
    --height=400 \
    --width=600 \
    $SCRIPTS_LIST) || exit 1

# Если ничего не выбрано - выходим
if [ -z "$SELECTED_SCRIPTS" ]; then
    zenity --error \
        --title="Ошибка" \
        --text="Не выбрано ни одного скрипта." \
        --width=300
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Выбираем директорию установки
INSTALL_DIR=$(zenity --file-selection \
    --title="Выберите директорию для установки" \
    --directory \
    --filename="$HOME/.local/bin") || exit 1

# Устанавливаем выбранные скрипты
(
echo "0"; echo "# Подготовка к установке..."

# Преобразуем строку с выбранными скриптами в массив
IFS='|' read -ra SCRIPT_ARRAY <<< "$SELECTED_SCRIPTS"
total_scripts=${#SCRIPT_ARRAY[@]}
current_script=0

for script in "${SCRIPT_ARRAY[@]}"; do
    current_script=$((current_script + 1))
    progress=$((current_script * 100 / total_scripts))
    
    # Убираем возможные пробелы
    script=$(echo "$script" | tr -d ' ')
    
    echo "$progress"
    echo "# Установка $script..."
    
    if [ -f "$TEMP_DIR/scripts/$script/install.sh" ]; then
        cd "$TEMP_DIR/scripts/$script"
        bash install.sh "$INSTALL_DIR"
    fi
done

echo "100"; echo "# Установка завершена!"
) | zenity --progress \
    --title="Установка" \
    --text="Начало установки..." \
    --percentage=0 \
    --auto-close \
    --width=300

# Очистка
rm -rf "$TEMP_DIR"

zenity --info \
    --title="Успех" \
    --text="Установка успешно завершена!\n\nПожалуйста, перезапустите терминал или выполните:\nsource ~/.bashrc" \
    --width=300