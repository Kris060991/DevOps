#!/bin/bash

# Функция для проверки параметров
check_parameters() {
  if [ $# -ne 1 ]; 
    then
      echo "Ошибка: Скрипт должен быть запущен с одним параметром."
      echo "Использование: $0 <путь_к_каталогу>/"
      exit 1
  fi

  if [[ ! "$1" =~ /$ ]]; 
    then
      echo "Ошибка: Путь должен заканчиваться на '/'"
      echo "Использование: $0 <путь_к_каталогу>/"
      exit 1
  fi

  if [ ! -d "$1" ]; 
    then
      echo "Ошибка: Каталог '$1' не существует или недоступен"
      exit 1
  fi
}

# Функция для форматирования размера
format_size() {
  local size=$1
  if [ $size -ge 1073741824 ]; 
    then
      echo "$(echo "scale=2; $size/1073741824" | bc) GB"
    elif [ $size -ge 1048576 ];
    then
      echo "$(echo "scale=2; $size/1048576" | bc) MB"
    elif [ $size -ge 1024 ]; 
    then
      echo "$(echo "scale=2; $size/1024" | bc) KB"
    else
      echo "${size} B"
  fi
}

# Функция для определения типа файла
get_file_type() {
  local file=$1
  local filename=$(basename "$file")
    
  case "${filename##*.}" in
    conf) echo "conf" ;;
    log) echo "log" ;;
    txt) echo "txt" ;;
    zip|tar|gz|bz2|rar|7z) echo "archive" ;;
    sh|exe|bin|run) echo "executable" ;;
    *) echo "other" ;;
  esac
}

# Функция для вычисления хеша
get_hash() {
  local file=$1
  if [ -f "$file" ] && [ -x "$file" ]; 
    then
      md5sum "$file" 2>/dev/null | cut -d' ' -f1
    else
      echo "N/A"
  fi
}