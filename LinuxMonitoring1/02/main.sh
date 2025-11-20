#!/bin/bash 

main() {
  # Источник всех функций
  local script_dir
  script_dir=$(dirname "$0")  # Получаем директорию, где лежит main.sh
  source "${script_dir}/info.sh"
  source "${script_dir}/output.sh"
  source "${script_dir}/file.sh"
    
  # Получаем всю информацию
  local all_info
  all_info=$(collect_all_info)
    
  # Разбираем информацию
  IFS='|' read -r hostname timezone user os date uptime uptime_sec ip mask gateway ram_total ram_used ram_free space_root space_root_used space_root_free <<< "$all_info"
    
  # Выводим информацию
  print_info "$hostname" "$timezone" "$user" "$os" "$date" "$uptime" "$uptime_sec" "$ip" "$mask" "$gateway" "$ram_total" "$ram_used" "$ram_free" "$space_root" "$space_root_used" "$space_root_free"
    
  echo ""
    
  # Спрашиваем о сохранении
  local answer
  answer=$(ask_to_save)
    
  if [ "$answer" = "yes" ]; then
      save_to_file "$hostname" "$timezone" "$user" "$os" "$date" "$uptime" "$uptime_sec" "$ip" "$mask" "$gateway" "$ram_total" "$ram_used" "$ram_free" "$space_root" "$space_root_used" "$space_root_free"
  else
      echo "Данные не сохранены."
  fi
}

# Запуск основной функции
main "$@"