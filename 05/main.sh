#!/bin/bash

# ==============================================
# PART 5: ИССЛЕДОВАНИЕ ФАЙЛОВОЙ СИСТЕМЫ
# ==============================================
# Скрипт запускается с одним параметром - путём к директории.
# Параметр должен заканчиваться знаком '/'.
# Выводит подробную информацию о каталоге.
# ==============================================

# Подключаем библиотеки
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/file_analyzer.sh"

# Функция показа справки
show_help() {
    cat << EOF
${BOLD}ИСПОЛЬЗОВАНИЕ:${RESET}
    $0 <путь_к_директории/>

${BOLD}ПАРАМЕТР:${RESET}
    Путь к директории, ОБЯЗАТЕЛЬНО заканчивающийся знаком '/'

${BOLD}ПРИМЕРЫ:${RESET}
    $0 /var/log/
    $0 /home/user/
    $0 ./test/

${BOLD}ВНИМАНИЕ:${RESET}
    Скрипт может работать долго на больших директориях.
    Требуются права на чтение исследуемой директории.
EOF
}

# Очищаем экран
clear

# Заголовок
echo -e "${BOLD}${BG_BLACK}${TEXT_GREEN}PART 5: ИССЛЕДОВАНИЕ ФАЙЛОВОЙ СИСТЕМЫ${RESET}"
print_separator "="

# Проверка количества параметров
if ! check_params_count $# 1; then
    echo -e "\n${BOLD}❌ ОШИБКА: Требуется 1 параметр!${RESET}"
    show_help
    exit 1
fi

# Получаем параметр
directory="$1"

# Проверка, что путь заканчивается на '/'
if ! check_path_ends_with_slash "$directory"; then
    log_error "Путь должен заканчиваться на '/'"
    show_help
    exit 1
fi

# Проверка существования директории
if ! check_directory "$directory"; then
    exit 1
fi

# Преобразуем в абсолютный путь, если нужно
if [[ "$directory" != /* ]]; then
    directory="$(cd "$(dirname "$directory")" 2>/dev/null && pwd)/$(basename "$directory")"
    # Восстанавливаем слеш на конце
    [[ "$directory" != */ ]] && directory="${directory}/"
fi

# Выводим информацию о начале анализа
echo -e "\n${BOLD}🔍 АНАЛИЗ ДИРЕКТОРИИ:${RESET} ${TEXT_PURPLE}$directory${RESET}"
echo -e "${ITALIC}Это может занять некоторое время...${RESET}\n"

# Запускаем таймер
start_timer

# Получаем информацию о директории
total_folders=$(count_folders "$directory")
total_files=$(count_files "$directory")
conf_files=$(count_conf_files "$directory")
text_files=$(count_text_files "$directory")
executable_files=$(count_executable_files "$directory")
log_files=$(count_log_files "$directory")
archive_files=$(count_archive_files "$directory")
symlinks=$(count_symlinks "$directory")

# Вывод основной информации
echo "${BOLD}📊 ОСНОВНАЯ ИНФОРМАЦИЯ:${RESET}"
echo "Total number of folders (including all nested ones) = ${TEXT_YELLOW}$total_folders${RESET}"
echo

# Топ-5 папок
echo "${BOLD}📁 TOP 5 folders of maximum size arranged in descending order (path and size):${RESET}"
if [[ $total_folders -gt 0 ]]; then
    top_folders "$directory" 5 | while read line; do
        echo "  $line"
    done
else
    echo "  ${ITALIC}Нет папок для анализа${RESET}"
fi
echo

# Информация о файлах
echo "${BOLD}📄 ИНФОРМАЦИЯ О ФАЙЛАХ:${RESET}"
echo "Total number of files = ${TEXT_YELLOW}$total_files${RESET}"
echo "Number of:"
echo "Configuration files (with the .conf extension) = ${TEXT_YELLOW}$conf_files${RESET}"
echo "Text files = ${TEXT_YELLOW}$text_files${RESET}"
echo "Executable files = ${TEXT_YELLOW}$executable_files${RESET}"
echo "Log files (with the extension .log) = ${TEXT_YELLOW}$log_files${RESET}"
echo "Archive files = ${TEXT_YELLOW}$archive_files${RESET}"
echo "Symbolic links = ${TEXT_YELLOW}$symlinks${RESET}"
echo

# Топ-10 файлов
echo "${BOLD}📊 TOP 10 files of maximum size arranged in descending order (path, size and type):${RESET}"
if [[ $total_files -gt 0 ]]; then
    top_files "$directory" 10 | while read line; do
        echo "  $line"
    done
else
    echo "  ${ITALIC}Нет файлов для анализа${RESET}"
fi
echo

# Топ-10 исполняемых файлов с хешами
echo "${BOLD}🔑 TOP 10 executable files of the maximum size arranged in descending order (path, size and MD5 hash of file):${RESET}"
if [[ $executable_files -gt 0 ]]; then
    top_executable_with_hash "$directory" 10 | while read line; do
        echo "  $line"
    done
else
    echo "  ${ITALIC}Нет исполняемых файлов для анализа${RESET}"
fi
echo

# Время выполнения
execution_time=$(end_timer)
formatted_time=$(format_execution_time "$execution_time")
echo "${BOLD}⏱ ВРЕМЯ ВЫПОЛНЕНИЯ:${RESET}"
echo "Script execution time (in seconds) = ${TEXT_YELLOW}$formatted_time${RESET}"

print_separator "-"

# Дополнительная статистика
echo -e "\n${BOLD}📈 ДОПОЛНИТЕЛЬНАЯ СТАТИСТИКА:${RESET}"

# Самый большой файл
largest_file=$(find "$directory" -type f -exec du -b {} \; 2>/dev/null | sort -nr | head -1)
if [[ -n "$largest_file" ]]; then
    size=$(echo "$largest_file" | awk '{print $1}')
    path=$(echo "$largest_file" | awk '{$1=""; print $0}' | sed 's/^ //')
    echo "Самый большой файл: $(format_bytes $size) - $(basename "$path")"
fi

# Количество пустых файлов
empty_files=$(find "$directory" -type f -empty 2>/dev/null | wc -l)
echo "Пустых файлов: $empty_files"

# Средний размер файла
if [[ $total_files -gt 0 ]]; then
    total_size=$(find "$directory" -type f -exec du -b {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}')
    if [[ -n "$total_size" ]]; then
        avg_size=$((total_size / total_files))
        echo "Средний размер файла: $(format_bytes $avg_size)"
    fi
fi

# Вердикт
echo
free_percent=$(get_memory_status 2>/dev/null || echo 85)
echo -e "${ITALIC}$(memory_verdict "$free_percent")${RESET}"

exit 0
