#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# ==============================================
# СБОР ИНФОРМАЦИИ О СИСТЕМЕ
# ==============================================

# HOSTNAME
get_hostname() {
    hostname
}

# TIMEZONE
get_timezone() {
    local timezone=$(cat /etc/timezone 2>/dev/null)
    local utc_offset=$(date +%z | sed 's/\(..\)\(..\)/\1:\2/')
    echo "$timezone UTC $utc_offset"
}

# USER
get_current_user() {
    whoami
}

# OS
get_os_info() {
    local os_info
    if [[ -f /etc/os-release ]]; then
        os_info=$(grep -w "PRETTY_NAME" /etc/os-release | cut -d= -f2 | tr -d '"')
    else
        os_info=$(uname -o)
    fi
    echo "$os_info"
}

# DATE
get_current_date() {
    date +"%d %B %Y %H:%M:%S"
}

# UPTIME
get_uptime() {
    uptime -p | sed 's/up //'
}

# UPTIME_SEC
get_uptime_sec() {
    cat /proc/uptime | awk '{print int($1)}'
}

# IP
get_ip() {
    ip route get 1 | awk '{print $7; exit}'
}

# MASK
get_netmask() {
    local interface=$(ip route get 1 | awk '{print $5; exit}')
    if [[ -n "$interface" ]]; then
        ifconfig "$interface" 2>/dev/null | grep -oP 'netmask \K\S+' || echo "255.255.255.0"
    else
        echo "255.255.255.0"
    fi
}

# GATEWAY
get_gateway() {
    ip route | grep default | awk '{print $3}'
}

# RAM_TOTAL (GB, 3 знака)
get_ram_total() {
    local total_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    echo "scale=3; $total_kb/1024/1024" | bc
}

# RAM_USED (GB, 3 знака)
get_ram_used() {
    local total_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local free_kb=$(grep MemFree /proc/meminfo | awk '{print $2}')
    local used_kb=$((total_kb - free_kb))
    echo "scale=3; $used_kb/1024/1024" | bc
}

# RAM_FREE (GB, 3 знака)
get_ram_free() {
    local free_kb=$(grep MemFree /proc/meminfo | awk '{print $2}')
    echo "scale=3; $free_kb/1024/1024" | bc
}

# SPACE_ROOT (MB, 2 знака)
get_root_space() {
    df / | awk 'NR==2 {print $2}' | while read size_kb; do
        echo "scale=2; $size_kb/1024" | bc
    done
}

# SPACE_ROOT_USED (MB, 2 знака)
get_root_space_used() {
    df / | awk 'NR==2 {print $3}' | while read used_kb; do
        echo "scale=2; $used_kb/1024" | bc
    done
}

# SPACE_ROOT_FREE (MB, 2 знака)
get_root_space_free() {
    df / | awk 'NR==2 {print $4}' | while read free_kb; do
        echo "scale=2; $free_kb/1024" | bc
    done
}

# Полная информация о системе (для Part 2)
get_full_system_info() {
    cat << EOF
HOSTNAME = $(get_hostname)
TIMEZONE = $(get_timezone)
USER = $(get_current_user)
OS = $(get_os_info)
DATE = $(get_current_date)
UPTIME = $(get_uptime)
UPTIME_SEC = $(get_uptime_sec)
IP = $(get_ip)
MASK = $(get_netmask)
GATEWAY = $(get_gateway)
RAM_TOTAL = $(get_ram_total) GB
RAM_USED = $(get_ram_used) GB
RAM_FREE = $(get_ram_free) GB
SPACE_ROOT = $(get_root_space) MB
SPACE_ROOT_USED = $(get_root_space_used) MB
SPACE_ROOT_FREE = $(get_root_space_free) MB
EOF
}

# Экспорт функций
export -f get_hostname get_timezone get_current_user get_os_info
export -f get_current_date get_uptime get_uptime_sec
export -f get_ip get_netmask get_gateway
export -f get_ram_total get_ram_used get_ram_free
export -f get_root_space get_root_space_used get_root_space_free
export -f get_full_system_info
