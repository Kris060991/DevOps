#!/bin/bash

# Функции логирования

LOG_FILE=""

init_logger() {
  local timestamp=$(date +%Y%m%d_%H%M%S)
  LOG_FILE="/var/log/generator_log_${timestamp}.txt"
    
  # Создание заголовка лог-файла
  echo "=== Журнал создания файлов ===" > "$LOG_FILE"
  echo "Время начала: $(date)" >> "$LOG_FILE"
}

log_entry() {
  local path="$1"
  local type="$2"
  local size="$3"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
  if [ "$type" = "directory" ]; 
    then
      echo "[$timestamp] DIR: $path" >> "$LOG_FILE"
    else
      echo "[$timestamp] FILE: $path | Size: $size bytes" >> "$LOG_FILE"
  fi
}

log_execution_time() {
  local start_time="$1"
  local end_time="$2"
  local total_time="$3"
    
  {
    echo ""
    echo "=== Сводка выполнения ==="
    echo "Время начала: $(date -d "@$start_time")"
    echo "Время окончания: $(date -d "@$end_time")"
    echo "Общее время выполнения: ${total_time} секунд"
  } >> "$LOG_FILE"
}
