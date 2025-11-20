#!/bin/bash

main() {
  local start_time=$(date +%s.%N)
    
  # Проверяем параметры
  source "$(dirname "$0")/additional_functions.sh"
  check_parameters "$@"
    
  local path="$1"
    
  # Подключаем функции анализа
  source "$(dirname "$0")/main_analysis_function.sh"
    
  echo "Total number of folders (including all nested ones) = $(count_folders "$path")"
  echo ""
    
  echo "TOP 5 folders of maximum size arranged in descending order (path and size):"
  get_top_folders "$path"
  echo ""
    
  echo "Total number of files = $(count_files "$path")"
  echo ""
    
  echo "Number of:"
  count_file_types "$path"
  echo ""
    
  echo "TOP 10 files of maximum size arranged in descending order (path, size and type):"
  get_top_files "$path"
  echo ""
    
  echo "TOP 10 executable files of the maximum size arranged in descending order (path, size and MD5 hash of file):"
  get_top_executables "$path"
  echo ""
    
  local end_time=$(date +%s.%N)
  local execution_time=$(echo "$end_time - $start_time" | bc)
  echo "Script execution time (in seconds) = $execution_time"
}

# Запуск основной функции
main "$@"