#!/bin/bash 

find_suitable_paths() {
  # Список проверенных путей которые обычно доступны для записи
  local possible_paths=(
    "/tmp"
    "/var/tmp"
    "/home/${USER}"
    "/home/${USER}/tmp"
    "/home/${USER}/Downloads"
    "/home/${USER}/Documents"
  )
    
  local suitable_paths=()
    
  for path in "${possible_paths[@]}"; 
    do
      # Создаем директорию если не существует
      if [ ! -d "$path" ]; 
        then
          mkdir -p "$path" 2>/dev/null
      fi
        
      # Проверяем доступность для записи
      if [ -d "$path" ] && [ -w "$path" ]; 
        then
          suitable_paths+=("$path")
          echo "Found suitable path: $path" >&2
      fi
    done
    
  # Если ничего не нашли, создаем временную директорию
  if [ ${#suitable_paths[@]} -eq 0 ]; 
    then
      local temp_dir="/tmp/file_generator_$$"
      mkdir -p "$temp_dir"
      suitable_paths+=("$temp_dir")
      echo "Created temp path: $temp_dir" >&2
  fi
    
  printf "%s\n" "${suitable_paths[@]}"
}

get_random_path() {
  local paths=("$@")
  local count=${#paths[@]}
  if [ $count -eq 0 ]; 
    then
      echo "/tmp"
      return 1
  fi
  local index=$((RANDOM % count))
  echo "${paths[index]}"
}