#!/bin/bash

# Функция для подсчета папок
count_folders() {
  local path=$1
  find "$path" -type d 2>/dev/null | wc -l
}

# Функция для поиска топ-5 самых больших папок
get_top_folders() {
  local path=$1
  du -h "$path" 2>/dev/null | sort -hr | head -6 | tail -5 | cat -n | while read num size path; do
    echo "$num - $path, $size"
  done
}

# Функция для подсчета файлов
count_files() {
  local path=$1
  find "$path" -type f 2>/dev/null | wc -l
}

# Функция для подсчета файлов по типам
count_file_types() {
  local path=$1
  local config_files=0
  local text_files=0
  local exec_files=0
  local log_files=0
  local archive_files=0
  local symlinks=0
    
  while IFS= read -r -d '' file; do
    case "$file" in
      *.conf) ((config_files++)) ;;
      *.txt) ((text_files++)) ;;
      *.log) ((log_files++)) ;;
      *.sh|*.exe|*.bin|*.run) 
        if [ -x "$file" ]; then
          ((exec_files++))
        fi
        ;;
      *.zip|*.tar|*.gz|*.bz2|*.rar|*.7z) ((archive_files++)) ;;
    esac
  done < <(find "$path" -type f -print0 2>/dev/null)
    
  symlinks=$(find "$path" -type l 2>/dev/null | wc -l)
    
  echo "Configuration files (with the .conf extension) = $config_files"
  echo "Text files = $text_files"
  echo "Executable files = $exec_files"
  echo "Log files (with the extension .log) = $log_files"
  echo "Archive files = $archive_files"
  echo "Symbolic links = $symlinks"
}

# Функция для поиска топ-10 самых больших файлов
get_top_files() {
  local path=$1
  find "$path" -type f -exec du -h {} + 2>/dev/null | sort -hr | head -10 | cat -n | while read num size path; do
    local file_type=$(get_file_type "$path")
    echo "$num - $path, $size, $file_type"
  done
}

# Функция для поиска топ-10 исполняемых файлов
get_top_executables() {
  local path=$1
  find "$path" -type f -executable -exec du -h {} + 2>/dev/null 2>/dev/null | sort -hr | head -10 | cat -n | while read num size path; do
    local hash=$(get_md5_hash "$path")
    echo "$num - $path, $size, $hash"
  done
}