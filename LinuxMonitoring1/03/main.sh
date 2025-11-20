#!/bin/bash 

# Проверка параметров
check_parameters() {
  if [ $# -ne 4 ]; 
    then
      echo "Ошибка: Скрипт должен быть запущен с 4 параметрами."
      echo "Использование: $0 <фон_имен> <цвет_имен> <фон_значений> <цвет_значений>"
      echo "Цвета: 1 - белый, 2 - красный, 3 - зеленый, 4 - синий, 5 - фиолетовый, 6 - черный"
      exit 1
  fi
    
  # Проверяем что все параметры - числа от 1 до 6
    if ! [[ "$1" =~ ^[1-6]$ ]] || ! [[ "$2" =~ ^[1-6]$ ]] || ! [[ "$3" =~ ^[1-6]$ ]] || ! [[ "$4" =~ ^[1-6]$ ]]; 
      then
        echo "Ошибка: Все параметры должны быть числами от 1 до 6."
        echo "Вы ввели: $1, $2, $3, $4"
        exit 1
    fi
}

main() {
  check_parameters "$@"

  local bg_names=$1  
  local fg_names=$2 
  local bg_values=$3 
  local fg_values=$4

  # Источник функций цветов для проверки
  local script_dir
  script_dir=$(dirname "$0")
  source "${script_dir}/colors.sh"

  # Проверяем цвета на совпадение
  if ! validate_colors "$bg_names" "$fg_names" "$bg_values" "$fg_values"; 
    then
      echo ""
      echo "Пожалуйста, запустите скрипт с другими параметрами."
      exit 1
  fi

  # Источник остальных функций
  source "${script_dir}/info.sh"
  source "${script_dir}/output.sh"

  # Получаем всю информацию
  local all_info
  all_info=$(collect_all_info)
    
  # Разбираем информацию
  IFS='|' read -r hostname timezone user os date uptime uptime_sec ip mask gateway ram_total ram_used ram_free space_root space_root_used space_root_free <<< "$all_info"
    
  # Выводим информацию с цветами
  print_colored_info "$bg_names" "$fg_names" "$bg_values" "$fg_values" "$hostname" "$timezone" "$user" "$os" "$date" "$uptime" "$uptime_sec" "$ip" "$mask" "$gateway" "$ram_total" "$ram_used" "$ram_free" "$space_root" "$space_root_used" "$space_root_free"
}

# Запуск основной функции
main "$@"
