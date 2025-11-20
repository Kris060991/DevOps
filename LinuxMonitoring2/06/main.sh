#!/bin/bash

# Определяем директорию скрипта
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../04/logs"
REPORT_DIR="/tmp"

# Проверяем существование лог-файлов
if ! ls "$LOG_DIR"/*.log &> /dev/null; then
    echo "Ошибка: Лог-файлы не найдены в $LOG_DIR"
    echo "Создайте сначала лог-файлы с помощью генератора"
    exit 1
fi

echo "Найдены лог-файлы:"
ls "$LOG_DIR"/*.log

# Создаем HTML отчет
echo "Создание отчета GoAccess..."
goaccess "$LOG_DIR"/*.log --log-format=COMBINED --output="$REPORT_DIR/index.html"

if [[ $? -eq 0 ]]; then
    echo "Отчет успешно создан: $REPORT_DIR/index.html"
else
    echo "Ошибка при создании отчета"
    exit 1
fi

# Запускаем веб-сервер
echo "Запуск веб-сервера на порту 8000..."
echo "Откройте в браузере: http://localhost:8000"
python3 -m http.server 8000 --directory "$REPORT_DIR"