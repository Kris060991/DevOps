#!/bin/bash

# Функции логирования

LOG_FILE=""

init_logger() {
  local base_path="$1"
  LOG_FILE="${base_path}/generation_log.txt"
    
  # Создание заголовка лог-файла
  echo "=== Журнал создания файлов ===" > "$LOG_FILE"
  echo "Время начала: $(date)" >> "$LOG_FILE"
  echo "Параметры: $@" >> "$LOG_FILE"
  echo "============================" >> "$LOG_FILE"
  echo "" >> "$LOG_FILE"
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