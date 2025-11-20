#!/bin/bash 

print_colored_info() {
  local bg_names=$1
  local fg_names=$2
  local bg_values=$3
  local fg_values=$4
  local hostname=$5
  local timezone=$6
  local user=$7
  local os=$8
  local date=$9
  local uptime=${10}
  local uptime_sec=${11}
  local ip=${12}
  local mask=${13}
  local gateway=${14}
  local ram_total=${15}
  local ram_used=${16}
  local ram_free=${17}
  local space_root=${18}
  local space_root_used=${19}
  local space_root_free=${20}

# Источник функций цветов
source "$(dirname "$0")/colors.sh"

# Устанавливаем цвета
local bg_names_code=$(set_background $bg_names)
local fg_names_code=$(set_foreground $fg_names)
local bg_values_code=$(set_background $bg_values)
local fg_values_code=$(set_foreground $fg_values)
local reset=$(reset_color)

# Вывод с цветами
echo -e "${bg_names_code}${fg_names_code}HOSTNAME = ${reset}${bg_values_code}${fg_values_code}$hostname${reset}"
echo -e "${bg_names_code}${fg_names_code}TIMEZONE = ${reset}${bg_values_code}${fg_values_code}$timezone${reset}"
echo -e "${bg_names_code}${fg_names_code}USER = ${reset}${bg_values_code}${fg_values_code}$user${reset}"
echo -e "${bg_names_code}${fg_names_code}OS = ${reset}${bg_values_code}${fg_values_code}$os${reset}"
echo -e "${bg_names_code}${fg_names_code}DATE = ${reset}${bg_values_code}${fg_values_code}$date${reset}"
echo -e "${bg_names_code}${fg_names_code}UPTIME = ${reset}${bg_values_code}${fg_values_code}$uptime${reset}"
echo -e "${bg_names_code}${fg_names_code}UPTIME_SEC = ${reset}${bg_values_code}${fg_values_code}$uptime_sec${reset}"
echo -e "${bg_names_code}${fg_names_code}IP = ${reset}${bg_values_code}${fg_values_code}$ip${reset}"
echo -e "${bg_names_code}${fg_names_code}MASK = ${reset}${bg_values_code}${fg_values_code}$mask${reset}"
echo -e "${bg_names_code}${fg_names_code}GATEWAY = ${reset}${bg_values_code}${fg_values_code}$gateway${reset}"
echo -e "${bg_names_code}${fg_names_code}RAM_TOTAL = ${reset}${bg_values_code}${fg_values_code}${ram_total} GB${reset}"
echo -e "${bg_names_code}${fg_names_code}RAM_USED = ${reset}${bg_values_code}${fg_values_code}${ram_used} GB${reset}"
echo -e "${bg_names_code}${fg_names_code}RAM_FREE = ${reset}${bg_values_code}${fg_values_code}${ram_free} GB${reset}"
echo -e "${bg_names_code}${fg_names_code}SPACE_ROOT = ${reset}${bg_values_code}${fg_values_code}${space_root} MB${reset}"
echo -e "${bg_names_code}${fg_names_code}SPACE_ROOT_USED = ${reset}${bg_values_code}${fg_values_code}${space_root_used} MB${reset}"
echo -e "${bg_names_code}${fg_names_code}SPACE_ROOT_FREE = ${reset}${bg_values_code}${fg_values_code}${space_root_free} MB${reset}"
}

collect_all_info() {
  # Источник функций info
  source "$(dirname "$0")/info.sh"

  # Получаем всю информацию
  local hostname=$(get_hostname)
  local timezone=$(get_timezone)
  local user=$(get_user)
  local os=$(get_os)
  local date=$(get_date)
  local uptime=$(get_uptime)
  local uptime_sec=$(get_uptime_sec)  
  local network_info=$(get_network_info)
  local ip=$(echo "$network_info" | cut -d'|' -f1)
  local mask=$(echo "$network_info" | cut -d'|' -f2)
  local gateway=$(echo "$network_info" | cut -d'|' -f3)   
  local ram_info=$(get_ram_info)
  local ram_total=$(echo "$ram_info" | cut -d'|' -f1)
  local ram_used=$(echo "$ram_info" | cut -d'|' -f2)
  local ram_free=$(echo "$ram_info" | cut -d'|' -f3)  
  local disk_info=$(get_disk_info)
  local space_root=$(echo "$disk_info" | cut -d'|' -f1)
  local space_root_used=$(echo "$disk_info" | cut -d'|' -f2)
  local space_root_free=$(echo "$disk_info" | cut -d'|' -f3)

  # Возвращаем все значения
  echo "${hostname}|${timezone}|${user}|${os}|${date}|${uptime}|${uptime_sec}|${ip}|${mask}|${gateway}|${ram_total}|${ram_used}|${ram_free}|${space_root}|${space_root_used}|${space_root_free}"
}