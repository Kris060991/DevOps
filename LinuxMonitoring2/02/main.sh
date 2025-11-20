#!/bin/bash 

# Основной скрипт
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/validators.sh"
source "$SCRIPT_DIR/path_finder.sh"
source "$SCRIPT_DIR/generator.sh"
source "$SCRIPT_DIR/logger.sh"

main() {
  local start_time=$(date +%s)
    
  # Проверка количества параметров
  if [ "$#" -ne 3 ]; 
    then
      echo "Ошибка: скрипту требуется ровно 3 параметра"
      echo "Использование: $0 <folder_chars> <file_chars> <file_size_mb>"
      echo "Пример: $0 az az.az 3Mb"
      exit 1
  fi
    
    # Параметры
  local folder_chars="$1"
  local file_chars="$2"
  local file_size_mb="$3"
    
  # Валидация параметров
  validate_folder_chars "$folder_chars"
  validate_file_chars "$file_chars"
  validate_file_size_mb "$file_size_mb"
    
  # Проверка свободного места
  check_disk_space
    
  # Инициализация логгера
  init_logger
    
  # Поиск подходящих путей
  echo "Поиск подходящих каталогов..."
  local paths=($(find_suitable_paths))
    
  if [ ${#paths[@]} -eq 0 ]; 
    then
      echo "Ошибка: подходящие каталоги не найдены"
      exit 1
  fi
    
  echo "Найдено ${#paths[@]} подходящих каталогов"
    
  # Генерация папок и файлов
  generate_folders_and_files "${paths[@]}" "$folder_chars" "$file_chars" "$file_size_mb"
    
  local end_time=$(date +%s)
  local total_time=$((end_time - start_time))
    
  # Запись времени выполнения
  log_execution_time "$start_time" "$end_time" "$total_time"
    
  echo "=== Генерация завершена ==="
  echo "Время начала: $(date -d @$start_time)"
  echo "Время окончания: $(date -d @$end_time)"
  echo "Общее время выполнения скрипта: ${total_time} секунд"
  echo "Файл журнала: /var/log/generator_log_$(date +%Y%m%d_%H%M%S).txt"
}

# Запуск основной функции
main "$@"