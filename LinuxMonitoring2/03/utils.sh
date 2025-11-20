#!/bin/bash

# Вспомогательные функции

validate_clean_method() {
  local method="$1"
  if [[ ! "$method" =~ ^[1-3]$ ]]; 
    then
      echo "Ошибка: метод очистки должен быть 1, 2 или 3"
      exit 1
  fi
}

confirm_deletion() {
  local count="$1"
  local type="$2"
    
  if [ "$count" -eq 0 ]; 
    then
      echo "Не найдено объектов для удаления."
      return 1
  fi
    
  echo "Найдено объектов для удаления: $count"
  read -p "Вы уверены, что хотите удалить эти $type? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; 
    then
      echo "Удаление отменено"
      return 1
  fi
  return 0
}

safe_remove() {
  local path="$1"
  local type="$2"
    
if [ "$type" = "file" ]; 
  then
    if [ -f "$path" ]; 
      then
        rm -f "$path"
        if [ $? -eq 0 ]; 
          then
            echo "Удален файл: $path"
          else
            echo "Ошибка при удалении файла: $path" >&2
        fi
    fi
  else
    if [ -d "$path" ]; 
      then
        rm -rf "$path"
        if [ $? -eq 0 ]; 
          then
            echo "Удалена папка: $path"
          else
            echo "Ошибка при удалении папки: $path" >&2
        fi
    fi
fi
}

find_log_files() {
  local log_files=()
    
  # Поиск файлов журнала в стандартных местах
  local possible_locations=(
    "/var/log/generator_log_*.txt"
    "$HOME/generator_log_*.txt"
    "/tmp/generator_log_*.txt"
  )
    
  for pattern in "${possible_locations[@]}"; 
    do
      for file in $pattern; 
        do
          if [ -f "$file" ]; 
            then
              log_files+=("$file")
          fi
        done
    done
    
  printf "%s\n" "${log_files[@]}"
}

parse_datetime_input() {
  local start_time=""
  local end_time=""
    
  echo "Введите временной интервал для удаления (формат: DD.MM.YY HH:MM)"
  echo "Формат: DD.MM.YY HH:MM или DD.MM.YYYY HH:MM"
  echo "Пример: 20.10.25 10:30 или 20.10.2025 10:30"
    
  # Получаем начальное время
  while true; do
    read -p "Начальное время: " start_input
    start_time=$(convert_to_timestamp "$start_input")
    if [[ "$start_time" =~ ^[0-9]+$ ]] && [ "$start_time" -gt 0 ]; 
      then
        break
      else
        echo "Ошибка: неверный формат времени. Используйте DD.MM.YY HH:MM или DD.MM.YYYY HH:MM"
      fi
  done
    
  # Получаем конечное время
  while true; do
    read -p "Конечное время: " end_input
    end_time=$(convert_to_timestamp "$end_input")
    if [[ "$end_time" =~ ^[0-9]+$ ]] && [ "$end_time" -gt 0 ]; 
      then
        if [ "$end_time" -ge "$start_time" ]; 
          then
            break
          else
            echo "Ошибка: конечное время должно быть после начального"
        fi
      else
        echo "Ошибка: неверный формат времени. Используйте DD.MM.YY HH:MM или DD.MM.YYYY HH:MM"
    fi
  done
    
  echo "$start_time $end_time"
}

validate_datetime() {
  local datetime="$1"
  if [[ "$datetime" =~ ^[0-9]{2}\.[0-9]{2}\.[0-9]{2,4}\ [0-9]{2}:[0-9]{2}$ ]]; 
    then
      return 0
  fi
  return 1
}

convert_to_timestamp() {
  local datetime="$1"

  # Проверяем корректность формата
  if ! validate_datetime "$datetime"; 
    then
      echo "0"
      return 1
  fi
  
  # Разбираем строку даты
  local day="${datetime:0:2}"
  local month="${datetime:3:2}"
  local year_part="${datetime:6:4}"
  local hour="${datetime:11:2}"
  local minute="${datetime:14:2}"

 # Если год указан как YYYY, обрезаем до YY
  if [ ${#year_part} -eq 4 ]; 
    then
      year_part="${year_part:2:2}"
  fi
    
  local year="20${year_part}"

  # Проверяем валидность даты
  if ! date -d "${year}-${month}-${day} ${hour}:${minute}" >/dev/null 2>&1; 
    then
      echo "0"
      return 1
  fi
    
  # Создаем временную метку
  local timestamp=$(date -d "${year}-${month}-${day} ${hour}:${minute}" +%s 2>/dev/null)
    
  if [ -z "$timestamp" ] || [ "$timestamp" -le 0 ]; 
    then
      echo "0"
    else
      echo "$timestamp"
  fi
}

# Функция для получения читаемой даты из timestamp
get_readable_date() {
  local timestamp="$1"
  if [[ "$timestamp" =~ ^[0-9]+$ ]] && [ "$timestamp" -gt 0 ]; 
    then
      date -d "@$timestamp" "+%d.%m.%Y %H:%M" 2>/dev/null || echo "неизвестно"
    else
      echo "неизвестно"
  fi
}