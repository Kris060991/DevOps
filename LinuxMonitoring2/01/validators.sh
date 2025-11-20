#!/bin/bash

# Функции валидации

validate_absolute_path() {
  local path="$1"
  if [[ ! "$path" =~ ^/ ]]; 
    then
      echo "Ошибка: Путь должен быть абсолютным (начинаться с /)"
      exit 1
  fi
}

validate_number() {
  local num="$1"
  local description="$2"
  if [[ ! "$num" =~ ^[0-9]+$ ]] || [ "$num" -le 0 ]; 
    then
      echo "Ошибка: $description должно быть положительным целым числом"
      exit 1
  fi
}

validate_folder_chars() {
  local chars="$1"
  if [[ ! "$chars" =~ ^[a-zA-Z]{1,7}$ ]]; 
    then
      echo "Ошибка: символы папки должны содержать от 1 до 7 английских букв."
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

validate_file_size() {
  local size="$1"
  if [[ ! "$size" =~ ^[0-9]+kb$ ]] || [ "${size%kb}" -gt 100 ]; 
    then
      echo "Ошибка: размер файла (в килобайтах, но не более 100)"
      exit 1
  fi
}

check_disk_space() {
  local free_space_gb
  free_space_gb=$(df / | awk 'NR==2 {print int($4/1024/1024)}')
    
  if [ "$free_space_gb" -le 1 ]; 
    then
      echo "Ошибка: в файловой системе осталось менее 1 ГБ свободного места."
      exit 1
  fi
}

create_directory() {
  local path="$1"
  if [ ! -d "$path" ]; 
    then
      mkdir -p "$path"
      if [ $? -ne 0 ];
        then
          echo "Ошибка: не удалось создать каталог $path"
          exit 1
      fi
  fi
}