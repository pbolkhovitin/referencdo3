#!/bin/bash

# ==============================================
# PART 4: КОНФИГУРИРОВАНИЕ ЦВЕТОВ
# ==============================================
# Скрипт запускается без параметров.
# Цвета берутся из конфигурационного файла config.cfg.
# Если параметры не заданы, используются значения по умолчанию.
# ==============================================

# Подключаем библиотеки
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/system_info.sh"
source "$SCRIPT_DIR/lib/colorscheme.sh"

# Очищаем экран
clear

# Заголовок
echo -e "${BOLD}${BG_BLACK}${TEXT_GREEN}PART 4: КОНФИГУРИРОВАНИЕ ЦВЕТОВОГО ОФОРМЛЕНИЯ${RESET}"
print_separator "="

# Проверка на отсутствие параметров
if [[ $# -gt 0 ]]; then
    log_warning "Скрипт запускается без параметров. Лишние параметры будут проигнорированы."
    echo -e "Использование: $0"
    sleep 2
fi

# Путь к конфигурационному файлу
CONFIG_FILE="$SCRIPT_DIR/04/config.cfg"

# Загружаем цветовую схему
echo -e "\n${BOLD}🔧 ЗАГРУЗКА КОНФИГУРАЦИИ...${RESET}"

declare -A COLOR_SCHEME
config_used="default"

if [[ -f "$CONFIG_FILE" ]]; then
    load_color_scheme "$CONFIG_FILE" COLOR_SCHEME
    config_used="file"
    log_success "Конфигурация загружена из файла: $CONFIG_FILE"
else
    load_color_scheme "" COLOR_SCHEME  # Загружаем значения по умолчанию
    log_warning "Файл конфигурации не найден. Используются цвета по умолчанию."
    echo -e "Ожидаемый файл: ${ITALIC}$CONFIG_FILE${RESET}"
fi

# Валидация цветовой схемы
if ! validate_color_scheme COLOR_SCHEME; then
    error_exit "Неверная цветовая схема. Исправьте конфигурационный файл."
fi

# Получаем значения цветов
bg_names="${COLOR_SCHEME[column1_background]}"
text_names="${COLOR_SCHEME[column1_font_color]}"
bg_values="${COLOR_SCHEME[column2_background]}"
text_values="${COLOR_SCHEME[column2_font_color]}"

# Получаем коды цветов
bg_names_code=$(get_background_code "$bg_names")
text_names_code=$(get_text_color_code "$text_names")
bg_values_code=$(get_background_code "$bg_values")
text_values_code=$(get_text_color_code "$text_values")

# Собираем информацию о системе
echo -e "\n${BOLD}📊 СБОР ИНФОРМАЦИИ О СИСТЕМЕ...${RESET}\n"

# Функция для цветного вывода строки
print_colored_line() {
    local label=$1
    local value=$2
    echo -e "${bg_names_code}${text_names_code}${label}${RESET} = ${bg_values_code}${text_values_code}${value}${RESET}"
}

# Вывод информации с применением цветов
print_colored_line "HOSTNAME" "$(get_hostname)"
print_colored_line "TIMEZONE" "$(get_timezone)"
print_colored_line "USER" "$(get_current_user)"
print_colored_line "OS" "$(get_os_info)"
print_colored_line "DATE" "$(get_current_date)"
print_colored_line "UPTIME" "$(get_uptime)"
print_colored_line "UPTIME_SEC" "$(get_uptime_sec)"
print_colored_line "IP" "$(get_ip)"
print_colored_line "MASK" "$(get_netmask)"
print_colored_line "GATEWAY" "$(get_gateway)"
print_colored_line "RAM_TOTAL" "$(printf "%.3f GB" "$(get_ram_total)")"
print_colored_line "RAM_USED" "$(printf "%.3f GB" "$(get_ram_used)")"
print_colored_line "RAM_FREE" "$(printf "%.3f GB" "$(get_ram_free)")"
print_colored_line "SPACE_ROOT" "$(printf "%.2f MB" "$(get_root_space)")"
print_colored_line "SPACE_ROOT_USED" "$(printf "%.2f MB" "$(get_root_space_used)")"
print_colored_line "SPACE_ROOT_FREE" "$(printf "%.2f MB" "$(get_root_space_free)")"

# Вывод информации о цветовой схеме (с отступом)
echo
print_separator "-"
echo -e "${BOLD}🎨 ЦВЕТОВАЯ СХЕМА:${RESET}"
print_color_scheme_report COLOR_SCHEME "$config_used"

# Показываем источник конфигурации
if [[ "$config_used" == "file" ]]; then
    echo -e "${ITALIC}Источник: файл конфигурации${RESET}"

    # Показываем содержимое конфига
    echo
    print_separator "-"
    echo -e "${BOLD}📄 СОДЕРЖИМОЕ config.cfg:${RESET}"
    if [[ -f "$CONFIG_FILE" ]]; then
        cat "$CONFIG_FILE" | while read line; do
            echo -e "  ${TEXT_CYAN}$line${RESET}"
        done
    fi
else
    echo -e "${ITALIC}Источник: значения по умолчанию${RESET}"
fi

print_separator "-"

# Вердикт
echo
free_percent=$(get_memory_status 2>/dev/null || echo 85)
echo -e "${ITALIC}$(memory_verdict "$free_percent")${RESET}"

exit 0
