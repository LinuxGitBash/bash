#!/bin/bash

# Проверяем root права
if [ "$EUID" -ne 0 ]; then
    if command -v zenity &> /dev/null; then
        zenity --error \
            --title="Ошибка" \
            --text="Запустите установщик с правами root:\nsudo ./install.sh" \
            --width=400
    else
        echo "Запустите установщик с правами root: sudo ./install.sh"
    fi
    exit 1
fi

# Устанавливаем базовые зависимости
echo "Установка базовых зависимостей..."
if command -v apt &> /dev/null; then
    apt install -y zenity git
elif command -v dnf &> /dev/null; then
    dnf install -y zenity git
elif command -v pacman &> /dev/null; then
    pacman -S --noconfirm zenity git
fi

# Функция для отображения прогресса
show_progress() {
    echo "$1" | zenity --progress --pulsate --title="$2" --text="$1" --auto-close --width=400
}

# Приветственное окно
zenity --info \
    --title="Bash Scripts Collection" \
    --text="<span size='large'>Добро пожаловать в установщик Bash Scripts Collection!</span>\n\nЭтот установщик поможет вам настроить полезные скрипты для Linux." \
    --ok-label="Начать установку" \
    --width=400 \
    --height=200

# Определяем директорию установки
INSTALL_DIR="/usr/local/bin"

# Клонируем репозиторий
TEMP_DIR=$(mktemp -d)
if ! git clone "https://github.com/LinuxGitBash/bash" "$TEMP_DIR" 2>/dev/null | show_progress "Загрузка скриптов..." "Подготовка"; then
    zenity --error \
        --title="Ошибка" \
        --text="Не удалось загрузить репозиторий.\nПроверьте подключение к интернету." \
        --width=400
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Создаем список доступных скриптов
SCRIPTS_LIST=""
for script_dir in "$TEMP_DIR"/scripts/*/; do
    if [ -d "$script_dir" ] && [ -f "$script_dir/install.sh" ]; then
        script_name=$(basename "$script_dir")
        description=$(head -n 1 "$script_dir/README.md" 2>/dev/null || echo "$script_name")
        features=$(sed -n '/Особенности:/,/^$/p' "$script_dir/README.md" | grep '^-' | sed 's/^- //' | tr '\n' '|' | sed 's/|$//')
        SCRIPTS_LIST="$SCRIPTS_LIST FALSE \"$script_name\" \"$description\" \"$features\""
    fi
done

# Показываем диалог выбора скриптов
SELECTED_SCRIPTS=$(eval zenity --list \
    --title="Выбор скриптов" \
    --text="Выберите скрипты для установки:" \
    --checklist \
    --column="✓" \
    --column="Скрипт" \
    --column="Описание" \
    --column="Возможности" \
    --height=500 \
    --width=800 \
    --ok-label="Установить" \
    --cancel-label="Отмена" \
    $SCRIPTS_LIST) || exit 1

# Если ничего не выбрано - выходим
if [ -z "$SELECTED_SCRIPTS" ]; then
    zenity --error \
        --title="Ошибка" \
        --text="Не выбрано ни одного скрипта." \
        --width=400
    rm -rf "$TEMP_DIR"
    exit 1
fi

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
    
    script=$(echo "$script" | tr -d ' ')
    echo "$progress"
    echo "# Установка: $script..."
    
    if [ -f "$TEMP_DIR/scripts/$script/install.sh" ]; then
        cd "$TEMP_DIR/scripts/$script"
        bash install.sh "$INSTALL_DIR"
    fi
done

echo "100"; echo "# Установка завершена!"
) | zenity --progress \
    --title="Установка скриптов" \
    --text="Начало установки..." \
    --percentage=0 \
    --auto-close \
    --width=400

# Очистка
rm -rf "$TEMP_DIR"

# Обновляем переменные окружения для текущего пользователя
su - $SUDO_USER -c "source ~/.bashrc"

# Показываем информацию о завершении
zenity --info \
    --title="Установка завершена" \
    --text="<span size='large'>Установка успешно завершена!</span>\n\nВыбранные скрипты установлены и готовы к использованию.\n\nПерезапустите систему для полного применения изменений." \
    --ok-label="Готово" \
    --width=400 \
    --height=200