#!/bin/bash 

# Коды цветов
WHITE='97'
RED='31'
GREEN='32'
BLUE='34'
PURPLE='35'
BLACK='30'
WHITE_BG='107'
RED_BG='41'
GREEN_BG='42'
BLUE_BG='44'
PURPLE_BG='45'
BLACK_BG='40'

# Цвета по умолчанию
DEFAULT_COLUMN1_BACKGROUND=6
DEFAULT_COLUMN1_FONT_COLOR=1
DEFAULT_COLUMN2_BACKGROUND=2
DEFAULT_COLUMN2_FONT_COLOR=4

# Функции для установки цветов
set_background() {
  local color=$1
  case $color in
    1) echo "\033[${WHITE_BG}m" ;;  
    2) echo "\033[${RED_BG}m"  ;;  
    3) echo "\033[${GREEN_BG}m"  ;;  
    4) echo "\033[${BLUE_BG}m"  ;;  
    5) echo "\033[${PURPLE_BG}m"  ;;  
    6) echo "\033[${BLACK_BG}m"  ;;  
    *) echo "" ;;
  esac
}

set_foreground() {
  local color=$1
  case $color in
    1) echo "\033[${WHITE}m"  ;;  
    2) echo "\033[${RED}m"    ;;  
    3) echo "\033[${GREEN}m"  ;;  
    4) echo "\033[${BLUE}m"   ;;  
    5) echo "\033[${PURPLE}m" ;;  
    6) echo "\033[${BLACK}m"  ;; 
    *) echo "" ;;
  esac
}

# Сброс цветов
reset_color() {
  echo "\033[0m"
}

# Функция для получения названия цвета
get_color_name() {
  case $1 in
    1) echo "белый" ;;
    2) echo "красный" ;;
    3) echo "зеленый" ;;
    4) echo "синий" ;;
    5) echo "фиолетовый" ;;
    6) echo "черный" ;;
    *) echo "неизвестный" ;;
  esac
}

# Проверка параметров
validate_colors() {
  local bg_names=$1
  local fg_names=$2
  local bg_values=$3
  local fg_values=$4
    
# Проверка на совпадение цветов в одном столбце
  if [ "$bg_names" -eq "$fg_names" ]; 
    then
      echo "Ошибка: Фон и цвет шрифта имен значений не должны совпадать."
      echo "Вы выбрали: фон=$bg_names ($(get_color_name $bg_names)), цвет шрифта=$fg_names ($(get_color_name $fg_names))"
    return 1
  fi
    
  if [ "$bg_values" -eq "$fg_values" ]; 
    then
      echo "Ошибка: Фон и цвет шрифта значений не должны совпадать."
      echo "Вы выбрали: фон=$bg_values ($(get_color_name $bg_values)), цвет шрифта=$fg_values ($(get_color_name $fg_values))"
    return 1
  fi
  return 0
}

# Загрузка конфигурации
load_config() {
  local config_file="$1"
  local -n col1_bg=$2  #-n создает ссылку на др переменную
  local -n col1_font=$3
  local -n col2_bg=$4
  local -n col2_font=$5
    
  # Значения по умолчанию
  col1_bg=$DEFAULT_COLUMN1_BACKGROUND
  col1_font=$DEFAULT_COLUMN1_FONT_COLOR
  col2_bg=$DEFAULT_COLUMN2_BACKGROUND
  col2_font=$DEFAULT_COLUMN2_FONT_COLOR
    
  # Если файл конфигурации существует, читаем из него
  if [ -f "$config_file" ]; 
    then
      while IFS='=' read -r key value; do
        # Пропускаем комментарии и пустые строки
        [[ $key =~ ^[[:space:]]*# ]] && continue
        [[ -z $key ]] && continue
            
        # Убираем пробелы
        key=$(echo "$key" | tr -d '[:space:]')
        value=$(echo "$value" | tr -d '[:space:]')
            
        case $key in
          column1_background)
            if [[ "$value" =~ ^[1-6]$ ]]; 
              then   
                col1_bg=$value
            fi
            ;;
          column1_font_color)
            if [[ "$value" =~ ^[1-6]$ ]]; 
              then
                col1_font=$value
            fi
            ;;
          column2_background)
             if [[ "$value" =~ ^[1-6]$ ]]; 
              then
                col2_bg=$value
              fi
              ;;
          column2_font_color)
            if [[ "$value" =~ ^[1-6]$ ]]; 
              then
                col2_font=$value
            fi
            ;;
          esac
      done < "$config_file"
  fi
}

# Вывод цветовой схемы
print_color_scheme() {
  local col1_bg=$1 # Фон для колонки 1 (имен параметров)
  local col1_font=$2 # Цвет текста для колонки 1
  local col2_bg=$3 # Фон для колонки 2 (значений)
  local col2_font=$4 # Цвет текста для колонки 2
    
  echo
  echo "Column 1 background = $(if [ $col1_bg -eq $DEFAULT_COLUMN1_BACKGROUND ]; then echo -n "default"; else echo -n "$col1_bg"; fi) ($(get_color_name $col1_bg))"
  echo "Column 1 font color = $(if [ $col1_font -eq $DEFAULT_COLUMN1_FONT_COLOR ]; then echo -n "default"; else echo -n "$col1_font"; fi) ($(get_color_name $col1_font))"
  echo "Column 2 background = $(if [ $col2_bg -eq $DEFAULT_COLUMN2_BACKGROUND ]; then echo -n "default"; else echo -n "$col2_bg"; fi) ($(get_color_name $col2_bg))"
  echo "Column 2 font color = $(if [ $col2_font -eq $DEFAULT_COLUMN2_FONT_COLOR ]; then echo -n "default"; else echo -n "$col2_font"; fi) ($(get_color_name $col2_font))"
}