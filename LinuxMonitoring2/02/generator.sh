#!/bin/bash 
# Функции генерации

generate_folder_name() {
  local chars="$1"
  local date_suffix=$(date +"%d%m%y")
    
  # Минимальная длина имени (без даты) - 5 символов
  local name_length=$((5 + RANDOM % 3))  # 5-7 символов
    
  local name=""
  local chars_length=${#chars}
    
  # Сначала добавляем все символы хотя бы по одному разу в порядке параметра
  for ((i=0; i<chars_length; i++)); 
    do
      name="${name}${chars:i:1}"
    done
    
  # Добавляем случайные символы до нужной длины (сохраняя порядок)
  while [ ${#name} -lt $name_length ]; 
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
    
  # Минимальная длина имени файла - 5 символов
  local name_length=$((5 + RANDOM % 3))  # 5-7 символов
  local ext_length=$((1 + RANDOM % 3))   # 1-3 символа
    
  local name=""
  local name_chars_length=${#name_chars}
  local ext_chars_length=${#ext_chars}
    
  # Генерация имени файла с использованием всех символов в порядке параметра
  for ((i=0; i<name_chars_length && ${#name} < name_length; i++)); 
    do
      name="${name}${name_chars:i:1}"
    done
    
  # Добираем до нужной длины
  while [ ${#name} -lt $name_length ]; 
    do
      local index=$((RANDOM % name_chars_length))
      name="${name}${name_chars:index:1}"
    done
    
  # Генерация расширения
  local extension=""
  for ((i=0; i<ext_chars_length && ${#extension} < ext_length; i++)); 
    do
      extension="${extension}${ext_chars:i:1}"
    done
    
  # Добираем расширение до нужной длины
  while [ ${#extension} -lt $ext_length ]; 
    do
      local index=$((RANDOM % ext_chars_length))
      extension="${extension}${ext_chars:index:1}"
    done
    
  echo "${name}_${date_suffix}.${extension}"
}

create_file_with_size() {
  local file_path="$1"
  local size_mb="$2"
    
  # Создание файла заданного размера (в мегабайтах)
  if ! dd if=/dev/zero of="$file_path" bs=1M count="${size_mb%Mb}" 2>/dev/null; 
    then
      echo "Ошибка: не удалось создать файл $file_path"
      return 1
  fi
  return 0
}

get_random_file_count() {
  # Случайное количество файлов от 1 до 50
  echo $((1 + RANDOM % 50))
}

generate_folders_and_files() {
  local paths=("${@:1:$#-3}")
  local folder_chars="${@: -3:1}"
  local file_chars="${@: -2:1}"
  local file_size_mb="${@: -1}"
    
  # Разделение параметров файла на имя и расширение
  local file_name_chars="${file_chars%.*}"
  local file_ext_chars="${file_chars#*.}"
    
  local folders_created=0
  local max_folders=100
    
  echo "Начало генерации в ${#paths[@]} разных местах"
  echo "Символы папки: $folder_chars, Символы файла: $file_chars, Размер файла: $file_size_mb"
    
  while [ $folders_created -lt $max_folders ]; 
    do
      # Проверка свободного места
      if ! check_disk_space_silent; 
        then
          echo "Предупреждение: генерация остановлена ​​из-за нехватки места на диске (менее 1 ГБ свободного места)"
          break
      fi
        
      # Выбор случайного пути
      local base_path
      base_path=$(get_random_path "${paths[@]}")
      if [ -z "$base_path" ]; 
        then
          echo "Error: No suitable paths available"
          break
      fi
        
      # Генерация имени папки
      local folder_name
      folder_name=$(generate_folder_name "$folder_chars")
      local folder_path="${base_path}/${folder_name}"
        
      # Создание папки
      if ! mkdir -p "$folder_path" 2>/dev/null; 
        then
          # Пропускаем если нет прав доступа
        continue
      fi
        
      log_entry "$folder_path" "directory" ""
      echo "Created folder: $folder_path"
      ((folders_created++))
        
      # Случайное количество файлов
      local file_count=$(get_random_file_count)
      local files_created=0
        
      # Создание файлов в папке
      for ((file_idx=0; file_idx<file_count; file_idx++)); 
        do
          # Проверка свободного места
          if ! check_disk_space_silent; 
            then
              echo "Предупреждение: генерация остановлена ​​из-за нехватки места на диске."
              break 2
          fi
            
          # Генерация имени файла
          local file_name
          file_name=$(generate_file_name "$file_name_chars" "$file_ext_chars")
          local file_path="${folder_path}/${file_name}"
            
          # Создание файла с заданным размером
          if create_file_with_size "$file_path" "$file_size_mb"; 
            then
              local file_size=$(stat -c%s "$file_path" 2>/dev/null || echo "0")
              log_entry "$file_path" "file" "$file_size"
              ((files_created++))
          fi
        done
        
      echo "Созданы файлы $files_created в $folder_path"
        
    done
    
  echo "Всего создано папок: $folders_created"
}