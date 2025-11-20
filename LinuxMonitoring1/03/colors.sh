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
    
  # Проверка диапазона параметров
  if 
    [ "$bg_names" -lt 1 ] || [ "$bg_names" -gt 6 ] ||
    [ "$fg_names" -lt 1 ] || [ "$fg_names" -gt 6 ] ||
    [ "$bg_values" -lt 1 ] || [ "$bg_values" -gt 6 ] ||
    [ "$fg_values" -lt 1 ] || [ "$fg_values" -gt 6 ]; 
    then
      echo "Ошибка: Все параметры должны быть числами от 1 до 6."
    return 1
  fi

  return 0
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