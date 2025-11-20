#!/bin/bash 

ask_to_save() {
  read -p "Хотите сохранить данные в файл? (Y/N): " answer
  case $answer in
    [Yy]* ) echo "yes" ;;
    * ) echo "no" ;;
  esac
}

save_to_file() {
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
  local filename=$(date +"%d_%m_%y_%H_%M_%S").status
   
    {
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
    } > "$filename"
    
  echo "Данные сохранены в файл: $filename"
}