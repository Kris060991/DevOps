#!/bin/bash

# Анализатор логов nginx с использованием awk

# Функция для получения всех лог-файлов
get_log_files() {
    local log_dir="$1"
    find "$log_dir" -name "*.log" -type f | sort
}

# 1. Все записи отсортированы по коду ответа
analyze_sorted_by_response_code() {
    local log_dir="$1"
    local output_file="${SCRIPT_DIR}/report_sorted_by_code.txt"
    
    echo "Отчет 1: Все записи, отсортированные по коду ответа"
    echo "Результат сохраняется в: $(basename "$output_file")"
    echo ""
    
    # Очищаем файл вывода
    > "$output_file"
    
    # Обрабатываем все лог-файлы
    for log_file in $(get_log_files "$log_dir"); do
        echo "Обработка: $(basename "$log_file")" >> "$output_file"
        echo "======================================" >> "$output_file"
        
        # AWK скрипт для сортировки по коду ответа
        # Код ответа находится в 9-м поле (после метода и URL)
        awk '
        {
            # Извлекаем код ответа (9-е поле)
            response_code = $9
            
            # Сохраняем всю строку с кодом ответа для сортировки
            print response_code " " $0
        }
        ' "$log_file" | sort -n | cut -d' ' -f2- >> "$output_file"
        
        echo "" >> "$output_file"
    done
    
    # Показываем статистику
    local total_lines=$(wc -l < "$output_file")
    echo "Всего записей в отчете: $((total_lines - 10))"  # Вычитаем заголовки
    echo "Полный отчет сохранен в: $output_file"
    
    # Показываем первые 20 строк для предпросмотра
    echo ""
    echo "Первые 20 записей:"
    head -20 "$output_file"
}

# 2. Все уникальные IP-адреса
analyze_unique_ips() {
    local log_dir="$1"
    local output_file="${SCRIPT_DIR}/report_unique_ips.txt"
    
    echo "Отчет 2: Все уникальные IP-адреса"
    echo "Результат сохраняется в: $(basename "$output_file")"
    echo ""
    
    # Очищаем файл вывода
    > "$output_file"
    
    # AWK скрипт для извлечения уникальных IP-адресов из всех файлов
    awk '
    {
        # IP адрес - первое поле в логе
        ip = $1
        
        # Сохраняем уникальные IP
        if (!seen[ip]++) {
            print ip
        }
    }
    ' $(get_log_files "$log_dir") | sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n > "$output_file"
    
    # Статистика
    local unique_count=$(wc -l < "$output_file")
    echo "Найдено уникальных IP-адресов: $unique_count"
    echo "Полный список сохранен в: $output_file"
    
    # Показываем первые 20 IP
    echo ""
    echo "Первые 20 IP-адресов:"
    head -20 "$output_file"
}

# 3. Все запросы с ошибками (код ответа 4xx или 5xx)
analyze_error_requests() {
    local log_dir="$1"
    local output_file="${SCRIPT_DIR}/report_error_requests.txt"
    
    echo "Отчет 3: Все запросы с ошибками (4xx или 5xx)"
    echo "Результат сохраняется в: $(basename "$output_file")"
    echo ""
    
    # Очищаем файл вывода
    > "$output_file"
    
    local total_errors=0
    
    # Обрабатываем каждый лог-файл
    for log_file in $(get_log_files "$log_dir"); do
        local file_errors=0
        
        # AWK скрипт для фильтрации ошибочных запросов
        awk '
        {
            # Извлекаем код ответа
            response_code = $9
            
            # Проверяем что код начинается с 4 или 5
            if (response_code ~ /^[45][0-9][0-9]$/) {
                print $0
            }
        }
        ' "$log_file" >> "$output_file"
        
        file_errors=$(awk '$9 ~ /^[45][0-9][0-9]$/ {count++} END {print count+0}' "$log_file")
        total_errors=$((total_errors + file_errors))
        
        echo "Файл $(basename "$log_file"): $file_errors ошибок" >> "$output_file"
        echo "======================================" >> "$output_file"
    done
    
    echo "Всего ошибочных запросов: $total_errors"
    echo "Полный отчет сохранен в: $output_file"
    
    # Показываем первые 15 ошибок
    if [ "$total_errors" -gt 0 ]; then
        echo ""
        echo "Первые 15 ошибочных запросов:"
        grep -E "^[0-9]" "$output_file" | head -15
    else
        echo "Ошибочных запросов не найдено"
    fi
}

# 4. Все уникальные IP-адреса среди ошибочных запросов
analyze_error_ips() {
    local log_dir="$1"
    local output_file="${SCRIPT_DIR}/report_error_ips.txt"
    
    echo "Отчет 4: Уникальные IP-адреса с ошибочными запросами"
    echo "Результат сохраняется в: $(basename "$output_file")"
    echo ""
    
    # Очищаем файл вывода
    > "$output_file"
    
    # AWK скрипт для извлечения уникальных IP из ошибочных запросов
    awk '
    {
        # Извлекаем код ответа и IP
        response_code = $9
        ip = $1
        
        # Проверяем что код начинается с 4 или 5
        if (response_code ~ /^[45][0-9][0-9]$/) {
            # Сохраняем уникальные IP
            if (!seen[ip]++) {
                print ip
            }
        }
    }
    ' $(get_log_files "$log_dir") | sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n > "$output_file"
    
    # Статистика
    local error_ip_count=$(wc -l < "$output_file")
    echo "Найдено уникальных IP с ошибочными запросами: $error_ip_count"
    echo "Полный список сохранен в: $output_file"
    
    # Показываем статистику по кодам ошибок
    echo ""
    echo "Статистика по кодам ошибок:"
    awk '
    {
        response_code = $9
        if (response_code ~ /^[45][0-9][0-9]$/) {
            error_codes[response_code]++
        }
    }
    END {
        for (code in error_codes) {
            printf "  Код %s: %d запросов\n", code, error_codes[code]
        }
    }
    ' $(get_log_files "$log_dir") | sort
    
    # Показываем первые 20 IP с ошибками
    if [ "$error_ip_count" -gt 0 ]; then
        echo ""
        echo "Первые 20 IP-адресов с ошибочными запросами:"
        head -20 "$output_file"
    fi
}