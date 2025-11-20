#!/bin/bash 

main() {
# Определяем путь к директории скрипта и конфигурационному файлу
  local script_dir
  script_dir=$(dirname "$0")
  local config_file="${script_dir}/config.conf"

   # Загружаем конфигурацию
  local column1_background column1_font_color column2_background column2_font_color
  source "${script_dir}/colors.sh"
  load_config "$config_file" column1_background column1_font_color column2_background column2_font_color

  # Проверяем цвета на совпадение
  if ! validate_colors "$column1_background" "$column1_font_color" "$column2_background" "$column2_font_color"; 
    then
      echo ""
      echo "Пожалуйста, исправьте конфигурационный файл: $config_file"
      exit 1
  fi

  # Источник остальных функций
  source "${script_dir}/system_info.sh"
  source "${script_dir}/output.sh"

  # Получаем всю информацию
  local all_info
  all_info=$(collect_all_info)
    
  # Разбираем информацию
  IFS='|' read -r hostname timezone user os date uptime uptime_sec ip mask gateway ram_total ram_used ram_free space_root space_root_used space_root_free <<< "$all_info"
    
  # Выводим информацию с цветами
  print_colored_info "$column1_background" "$column1_font_color" "$column2_background" "$column2_font_color" "$hostname" "$timezone" "$user" "$os" "$date" "$uptime" "$uptime_sec" "$ip" "$mask" "$gateway" "$ram_total" "$ram_used" "$ram_free" "$space_root" "$space_root_used" "$space_root_free"
    
  # Выводим цветовую схему
  print_color_scheme "$column1_background" "$column1_font_color" "$column2_background" "$column2_font_color"
}

# Запуск основной функции
main "$@"