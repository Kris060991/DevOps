#!/bin/bash

# Основной скрипт очистки
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/cleaner_methods.sh"
source "$SCRIPT_DIR/utils.sh"

# Главная функция
main() {
  echo "=== Скрипт очистки системы ==="
  echo "Время начала: $(date)"

  # Проверка количества параметров
  if [ "$#" -ne 1 ]; 
    then
      echo "Ошибка: скрипту требуется ровно 1 параметр"
      echo "Использование: $0 <метод_очистки>"
      echo "Методы очистки:"
      echo "1 - По файлу журнала"
      echo "2 - По дате и времени создания" 
      echo "3 - По маске имени"
      exit 1
  fi

  local method="$1"
    
  # Валидация параметров
  validate_clean_method "$method"
    
  case "$method" in
    1)
      echo "Выбран метод: Очистка по файлу журнала"
      clean_by_log
      ;;
    2)
      echo "Выбран метод: Очистка по дате и времени создания"
      clean_by_datetime
      ;;
    3)
      echo "Выбран метод: Очистка по маске имени"
      clean_by_name_mask
      ;;
  esac
    
  echo "=== Очистка завершена ==="
  echo "Время окончания: $(date)"
}

# Запуск главной функции
main "$@"