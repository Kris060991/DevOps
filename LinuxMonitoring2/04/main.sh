#!/bin/bash

# Определяем директорию скрипта для подключения зависимостей
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Подключаем модули
source "$SCRIPT_DIR/generator.sh"

main() {
    echo "Начало генерации..."

    # Создаем папку logs если не существует
    mkdir -p "$SCRIPT_DIR/logs"
    
    for i in {0..4}; do
        # Вычисляем дату для дня назад
        log_date=$(date -d "today - $i days" +"%Y-%m-%d")
        log_filename="$SCRIPT_DIR/logs/access-${log_date}.log"

        # Генерируем случайное количество записей
        num_entries=$((RANDOM % 901 + 100))

        echo "Генерация $num_entries записей для $log_date в $log_filename..."

        # Очищаем файл перед записью
        > "$log_filename"

        for ((j=0; j<num_entries; j++)); do
            generate_log_entry "$log_date" >> "$log_filename"
        done

        echo "Файл $log_filename создан"

        # Сортировка по дате (поле между [ и ])
        tmpfile="${log_filename}.tmp"
        sort -t'[' -k2 "$log_filename" > "$tmpfile"
        mv "$tmpfile" "$log_filename"
    done

    echo "Создание журнала успешно завершено!"
}

main
exit 0