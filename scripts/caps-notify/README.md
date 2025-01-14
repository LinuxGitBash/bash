Уведомления о состоянии Caps Lock

Особенности:
- Показывает уведомления при включении/выключении Caps Lock
- Автоматический запуск при старте системы через systemd
- Работает в фоновом режиме
- Минимальное потребление ресурсов
- Автоматическое восстановление после сбоев

Требования:
- Linux с systemd
- X11 (xset)
- libnotify (notify-send)

Команды:
- caps_notify.sh - запуск сервиса вручную
- caps_notify_stop.sh - остановка сервиса

Установка:
1. Автоматическая (рекомендуется):
   - Используйте главный установщик
   - Выберите "caps-notify" из списка

2. Ручная:
   ```bash
   sudo mkdir -p /usr/local/bin
   sudo cp caps_notify.sh /usr/local/bin/
   sudo cp stop.sh /usr/local/bin/caps_notify_stop.sh
   sudo chmod +x /usr/local/bin/caps_notify.sh
   sudo chmod +x /usr/local/bin/caps_notify_stop.sh
   ```

Устранение проблем:
1. Если скрипт не запускается:
   - Проверьте права на директорию установки
   - Убедитесь, что systemd работает: `systemctl --user status caps-notify`
   - Проверьте логи: `journalctl --user -u caps-notify`

2. Если нет уведомлений:
   - Проверьте наличие notify-send: `which notify-send`
   - Убедитесь, что работает система уведомлений

3. Если не работает после перезагрузки:
   - Включите сервис: `systemctl --user enable caps-notify`
   - Запустите сервис: `systemctl --user start caps-notify` 