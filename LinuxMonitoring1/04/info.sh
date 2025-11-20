#!/bin/bash 

#!/bin/bash 

get_hostname() {
  hostname
}

get_timezone() {
  local timezone=$(timedatectl show --property=Timezone --value 2>/dev/null)
  local offset=$(date +%z)
  local offset_formatted="${offset:0:3}:${offset:3:2}"
  echo "$timezone UTC $offset_formatted"
}

get_user() {
  whoami
}

get_os() {
  grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"'
}

get_date() {
  date "+%d %B %Y г., %H:%M:%S"
}

get_uptime() {
  uptime -p | sed 's/up //'
}

get_uptime_sec() {
  awk '{print $1}' /proc/uptime | cut -d. -f1
}

get_network_info() {
  local interface=$(ip route get 1 2>/dev/null | awk '{print $5; exit}')
  local ip=$(ip addr show "$interface" 2>/dev/null | grep -w "inet" | awk '{print $2}' | cut -d/ -f1)
  local mask=$(ip addr show "$interface" 2>/dev/null | grep -w "inet" | awk '{print $4}')
  local gateway=$(ip route 2>/dev/null | grep default | awk '{print $3}')
    
  echo "$ip|$mask|$gateway"
}

get_ram_info() {
  local ram_total_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  local ram_free_kb=$(grep MemFree /proc/meminfo | awk '{print $2}')
  local ram_buffer_kb=$(grep Buffers /proc/meminfo | awk '{print $2}')
  local ram_cached_kb=$(grep -w "Cached" /proc/meminfo | awk '{print $2}')
    
  local ram_total_gb=$(echo "scale=3; $ram_total_kb / 1024 / 1024" | bc)
  local ram_free_gb=$(echo "scale=3; $ram_free_kb / 1024 / 1024" | bc)
  local ram_used_gb=$(echo "scale=3; ($ram_total_kb - $ram_free_kb - $ram_buffer_kb - $ram_cached_kb) / 1024 / 1024" | bc)
    
  echo "${ram_total_gb}|${ram_used_gb}|${ram_free_gb}"
}

get_disk_info() {
  local root_total=$(df / | awk 'NR==2 {printf "%.2f", $2/1024}')
  local root_used=$(df / | awk 'NR==2 {printf "%.2f", $3/1024}')
  local root_free=$(df / | awk 'NR==2 {printf "%.2f", $4/1024}')
    
  echo "${root_total}|${root_used}|${root_free}"
}
