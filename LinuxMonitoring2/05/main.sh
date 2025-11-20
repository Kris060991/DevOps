#!/bin/bash

# Основной скрипт анализа логов nginx
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/analyzer.sh"

main() {
    echo "=== Анализатор логов nginx ==="
    echo "Время начала: $(date)"
    
    # Проверка количества параметров
    if [ "$#" -ne 1 ]; then
        echo "Ошибка: скрипту требуется ровно 1 параметр"
        echo "Использование: $0 <номер_отчета>"
        echo "Доступные отчеты:"
        echo "  1 - Все записи, отсортированные по коду ответа"
        echo "  2 - Все уникальные IP-адреса"
        echo "  3 - Все запросы с ошибками (4xx или 5xx)"
        echo "  4 - Уникальные IP-адреса с ошибочными запросами"
        exit 1
    fi
    
    local report_type="$1"
    local log_dir="${SCRIPT_DIR}/../04/logs"
    
    # Проверяем существование директории с логами
    if [ ! -d "$log_dir" ]; then
        echo "Ошибка: директория с логами не найдена: $log_dir"
        echo "Сначала запустите генератор логов из части 4"
        exit 1
    fi
    
    # Проверяем что есть лог-файлы
    local log_files=("$log_dir"/*.log)
    if [ ${#log_files[@]} -eq 0 ] || [ ! -f "${log_files[0]}" ]; then
        echo "Ошибка: лог-файлы не найдены в $log_dir"
        echo "Сначала запустите генератор логов из части 4"
        exit 1
    fi
    
    echo "Анализ логов из: $log_dir"
    echo "Тип отчета: $report_type"
    echo " "
    
    # Выполняем анализ в зависимости от типа отчета
    case "$report_type" in
        1)
            analyze_sorted_by_response_code "$log_dir"
            ;;
        2)
            analyze_unique_ips "$log_dir"
            ;;
        3)
            analyze_error_requests "$log_dir"
            ;;
        4)
            analyze_error_ips "$log_dir"
            ;;
        *)
            echo "Ошибка: неверный тип отчета. Используйте 1, 2, 3 или 4"
            exit 1
            ;;
    esac
    
    echo " "
    echo "Анализ завершен: $(date)"
}

# Запуск основной функции
main "$@"