#!/bin/bash 

print_info() {
  local hostname=$1
  local timezone=$2
  local user=$3
  local os=$4
  local date=$5
  local uptime=$6
  local uptime_sec=$7
  local ip=$8
  local mask=$9
  local gateway=${10}
  local ram_total=${11}
  local ram_used=${12}
  local ram_free=${13}
  local space_root=${14}
  local space_root_used=${15}
  local space_root_free=${16}

  echo "HOSTNAME = $hostname"
  echo "TIMEZONE = $timezone"
  echo "USER = $user"
  echo "OS = $os"
  echo "DATE = $date"
  echo "UPTIME = $uptime"
  echo "UPTIME_SEC = $uptime_sec"
  echo "IP = $ip"
  echo "MASK = $mask"
  echo "GATEWAY = $gateway"
  echo "RAM_TOTAL = ${ram_total} GB"
  echo "RAM_USED = ${ram_used} GB"
  echo "RAM_FREE = ${ram_free} GB"
  echo "SPACE_ROOT = ${space_root} MB"
  echo "SPACE_ROOT_USED = ${space_root_used} MB"
  echo "SPACE_ROOT_FREE = ${space_root_free} MB"
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