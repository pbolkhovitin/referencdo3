#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# ==============================================
# АНАЛИЗ ФАЙЛОВОЙ СИСТЕМЫ
# ==============================================

# Подсчёт общего числа папок
count_folders() {
    local dir=$1
    find "$dir" -type d 2>/dev/null | wc -l
}

# Топ-5 папок по размеру
top_folders() {
    local dir=$1
    local limit=${2:-5}

    du -h "$dir" 2>/dev/null | sort -rh | head -n "$limit" | nl -w2 -s' - '
}

# Общее число файлов
count_files() {
    local dir=$1
    find "$dir" -type f 2>/dev/null | wc -l
}

# Подсчёт файлов по расширениям
count_files_by_extension() {
    local dir=$1
    local ext=$2

    if [[ -n "$ext" ]]; then
        find "$dir" -type f -name "*$ext" 2>/dev/null | wc -l
    else
        find "$dir" -type f 2>/dev/null | wc -l
    fi
}

# Подсчёт конфигурационных файлов (.conf)
count_conf_files() {
    local dir=$1
    find "$dir" -type f -name "*.conf" 2>/dev/null | wc -l
}

# Подсчёт текстовых файлов
count_text_files() {
    local dir=$1
    find "$dir" -type f -name "*.txt" 2>/dev/null | wc -l
}

# Подсчёт исполняемых файлов
count_executable_files() {
    local dir=$1
    find "$dir" -type f -executable 2>/dev/null | wc -l
}

# Подсчёт лог-файлов (.log)
count_log_files() {
    local dir=$1
    find "$dir" -type f -name "*.log" 2>/dev/null | wc -l
}

# Подсчёт архивов
count_archive_files() {
    local dir=$1
    find "$dir" -type f \( -name "*.tar" -o -name "*.gz" -o -name "*.zip" -o -name "*.7z" -o -name "*.rar" \) 2>/dev/null | wc -l
}

# Подсчёт символических ссылок
count_symlinks() {
    local dir=$1
    find "$dir" -type l 2>/dev/null | wc -l
}

# Топ-10 файлов по размеру
top_files() {
    local dir=$1
    local limit=${2:-10}

    find "$dir" -type f -exec du -b {} \; 2>/dev/null | sort -nr | head -n "$limit" | while read size path; do
        local size_hr=$(format_bytes "$size")
        local ext="${path##*.}"
        echo "$(printf "%2d" $((++i))) - $path, $size_hr, $ext"
    done
}

# Топ-10 исполняемых файлов по размеру с MD5
top_executable_with_hash() {
    local dir=$1
    local limit=${2:-10}
    local i=0

    find "$dir" -type f -executable -exec du -b {} \; 2>/dev/null | sort -nr | head -n "$limit" | while read size path; do
        local size_hr=$(format_bytes "$size")
        local hash=$(md5sum "$path" 2>/dev/null | awk '{print $1}')
        echo "$(printf "%2d" $((++i))) - $path, $size_hr, $hash"
    done
}

# Полная информация о директории (для Part 5)
get_full_directory_info() {
    local dir=$1
    local start_time=$(date +%s.%N)

    echo "Total number of folders (including all nested ones) = $(count_folders "$dir")"
    echo "TOP 5 folders of maximum size arranged in descending order (path and size):"
    top_folders "$dir" 5
    echo "Total number of files = $(count_files "$dir")"
    echo "Number of:"
    echo "Configuration files (with the .conf extension) = $(count_conf_files "$dir")"
    echo "Text files = $(count_text_files "$dir")"
    echo "Executable files = $(count_executable_files "$dir")"
    echo "Log files (with the extension .log) = $(count_log_files "$dir")"
    echo "Archive files = $(count_archive_files "$dir")"
    echo "Symbolic links = $(count_symlinks "$dir")"
    echo "TOP 10 files of maximum size arranged in descending order (path, size and type):"
    top_files "$dir" 10
    echo "TOP 10 executable files of the maximum size arranged in descending order (path, size and MD5 hash of file):"
    top_executable_with_hash "$dir" 10

    local end_time=$(date +%s.%N)
    local elapsed=$(echo "$end_time - $start_time" | bc)
    echo "Script execution time (in seconds) = $(printf "%.2f" "$elapsed")"
}

# Экспорт функций
export -f count_folders top_folders count_files
export -f count_files_by_extension count_conf_files count_text_files
export -f count_executable_files count_log_files count_archive_files count_symlinks
export -f top_files top_executable_with_hash get_full_directory_info
