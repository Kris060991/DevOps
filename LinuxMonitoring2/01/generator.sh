#!/bin/bash

# Функции генерации

generate_folder_name() {
  local chars="$1"
  local date_suffix=$(date +"%d%m%y")
    
  # Минимальная длина имени (без даты) - 4 символа
  local name_length=$((4 + RANDOM % 4))
    
  local name=""
  local chars_length=${#chars}
    
  # Генерация имени с сохранением порядка символов
  for ((i=0; i<name_length; i++)); 
    do
      local index=$((RANDOM % chars_length))
      name="${name}${chars:index:1}"
    done
    
    echo "${name}_${date_suffix}"
}

generate_file_name() {
  local name_chars="$1"
  local ext_chars="$2"
  local date_suffix=$(date +"%d%m%y")
    
  # Минимальная длина имени файла - 4 символа
  local name_length=$((4 + RANDOM % 4))
  local ext_length=$((1 + RANDOM % 3))
    
  local name=""
  local name_chars_length=${#name_chars}
  local ext_chars_length=${#ext_chars}
    
  # Генерация имени файла
  for ((i=0; i<name_length; i++)); 
    do
      local index=$((RANDOM % name_chars_length))
      name="${name}${name_chars:index:1}"
    done
    
  # Генерация расширения
  local extension=""
  for ((i=0; i<ext_length; i++)); 
    do
      local index=$((RANDOM % ext_chars_length))
      extension="${extension}${ext_chars:index:1}"
    done
    
  echo "${name}_${date_suffix}.${extension}"
}

create_file_with_size() {
  local file_path="$1"
  local size_kb="$2"
    
  # Создание файла заданного размера
  dd if=/dev/zero of="$file_path" bs=1K count="${size_kb%kb}" 2>/dev/null
}

generate_folders_and_files() {
  local base_path="$1"
  local num_folders="$2"
  local folder_chars="$3"
  local num_files="$4"
  local file_chars="$5"
  local file_size_kb="$6"
    
  # Разделение параметров файла на имя и расширение
  local file_name_chars="${file_chars%.*}"
  local file_ext_chars="${file_chars#*.}"
    
  echo "Начало генерации в: $base_path"
  echo "Папки: $num_folders, Файлы в папке: $num_files"
    
  for ((folder_idx=0; folder_idx<num_folders; folder_idx++)); 
    do
      # Проверка свободного места перед каждой операцией
      check_disk_space
        
      # Генерация имени папки
      local folder_name
      folder_name=$(generate_folder_name "$folder_chars")
      local folder_path="${base_path}/${folder_name}"
        
      # Создание папки
      mkdir -p "$folder_path"
      log_entry "$folder_path" "directory" ""
        
      echo "Созданная папка: $folder_path"
        
      # Создание файлов в папке
      for ((file_idx=0; file_idx<num_files; file_idx++)); 
        do
          # Проверка свободного места
          check_disk_space
            
          # Генерация имени файла
          local file_name
          file_name=$(generate_file_name "$file_name_chars" "$file_ext_chars")
          local file_path="${folder_path}/${file_name}"
            
          # Создание файла с заданным размером
          create_file_with_size "$file_path" "$file_size_kb"
          local file_size=$(stat -c%s "$file_path" 2>/dev/null || echo "0")
            
          log_entry "$file_path" "file" "$file_size"
            
          echo "Созданный файл: $file_path (${file_size_kb})"
        done
    done
}
