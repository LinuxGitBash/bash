#!/bin/bash

# Проверяем root права
if [ "$EUID" -ne 0 ]; then
    if command -v zenity &> /dev/null; then
        zenity --error \
            --title="Ошибка" \
            --text="Запустите скрипт удаления с правами root:\nsudo ./uninstall.sh" \
            --width=400
    else
        echo "Запустите скрипт удаления с правами root: sudo ./uninstall.sh"
    fi
    exit 1
fi

# Функция для удаления caps-notify
remove_caps_notify() {
    echo "Удаление Caps Lock Notify..."
    systemctl stop caps-notify.service 2>/dev/null
    systemctl disable caps-notify.service 2>/dev/null
    rm -f /etc/systemd/system/caps-notify.service
    rm -f /usr/local/bin/caps_notify.sh
    rm -f /usr/local/bin/caps_notify_stop.sh
    rm -f /etc/profile.d/caps-notify.sh
}

# Функция для удаления keyboard-layout
remove_keyboard_layout() {
    echo "Удаление Keyboard Layout..."
    rm -f /usr/local/bin/keyboard_layout.sh
    rm -f /usr/local/bin/keyboard_layout_stop.sh
    setxkbmap -layout us -option ''
}

# Показываем диалог выбора компонентов для удаления
COMPONENTS=$(zenity --list \
    --title="Выбор компонентов для удаления" \
    --text="Выберите компоненты для удаления:" \
    --checklist \
    --column="✓" \
    --column="Компонент" \
    --column="Описание" \
    FALSE "caps-notify" "Уведомления о состоянии Caps Lock" \
    FALSE "keyboard-layout" "Переключение раскладки клавиатуры" \
    --height=300 \
    --width=500) || exit 0

# Если ничего не выбрано - выходим
if [ -z "$COMPONENTS" ]; then
    zenity --error \
        --title="Ошибка" \
        --text="Не выбрано ни одного компонента." \
        --width=300
    exit 1
fi

# Удаляем выбранные компоненты
echo "Начало удаления..."

if [[ $COMPONENTS == *"caps-notify"* ]]; then
    remove_caps_notify
fi

if [[ $COMPONENTS == *"keyboard-layout"* ]]; then
    remove_keyboard_layout
fi

# Перезагружаем systemd
systemctl daemon-reload

zenity --info \
    --title="Удаление завершено" \
    --text="Выбранные компоненты успешно удалены.\nПерезагрузите систему для полного применения изменений." \
    --width=400 