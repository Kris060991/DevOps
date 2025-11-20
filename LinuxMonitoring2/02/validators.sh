#!/bin/bash

# Функции валидации

validate_folder_chars() {
  local chars="$1"
  if [[ ! "$chars" =~ ^[a-zA-Z]{1,7}$ ]]; 
    then
      echo "Ошибка: символы папки должны содержать от 1 до 7 английских букв"
      exit 1
  fi
}

validate_file_chars() {
  local chars="$1"
  if [[ ! "$chars" =~ ^[a-zA-Z]{1,7}\.[a-zA-Z]{1,3}$ ]]; 
    then
      echo "Ошибка: символы файла должны быть в формате «имя_символов.расширение_символов» (например, «az.az»). не более 7 символов для названия, не более 3 символов для расширения"
      exit 1
  fi
}

validate_file_size_mb() {
  local size="$1"
  if [[ ! "$size" =~ ^[0-9]+Mb$ ]] || [ "${size%Mb}" -gt 100 ] || [ "${size%Mb}" -le 0 ]; 
    then
      echo "Ошибка: размер файла (в мегабайтах, но не более 100)"
      exit 1
  fi
}

check_disk_space() {
  local free_space_gb
  free_space_gb=$(df / | awk 'NR==2 {print int($4/1024/1024)}')
    
  if [ "$free_space_gb" -le 1 ]; 
    then
      echo "Ошибка: в файловой системе осталось менее 1 ГБ свободного места"
      exit 1
  fi
}

check_disk_space_silent() {
  local free_space_gb
  free_space_gb=$(df / | awk 'NR==2 {print int($4/1024/1024)}')
  [ "$free_space_gb" -gt 1 ]
}