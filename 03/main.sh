#!/bin/bash

# ==============================================
# PART 3: ВИЗУАЛЬНОЕ ОФОРМЛЕНИЕ
# ==============================================
# Скрипт запускается с 4 параметрами (цвета):
# 1 - фон названий значений
# 2 - цвет шрифта названий значений
# 3 - фон значений
# 4 - цвет шрифта значений
# Цвета: 1-white, 2-red, 3-green, 4-blue, 5-purple, 6-black
# ==============================================

# Подключаем библиотеки
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/system_info.sh"
source "$SCRIPT_DIR/lib/colorscheme.sh"

# Функция показа справки
show_help() {
    cat << EOF
${BOLD}ИСПОЛЬЗОВАНИЕ:${RESET}
    $0 <фон_названий> <цвет_названий> <фон_значений> <цвет_значений>

${BOLD}ПАРАМЕТРЫ (числа от 1 до 6):${RESET}
    1 - white (белый)
    2 - red (красный)
    3 - green (зеленый)
    4 - blue (синий)
    5 - purple (фиолетовый)
    6 - black (черный)

${BOLD}ПРИМЕР:${RESET}
    $0 1 3 4 6
    (фон названий: белый, текст названий: зеленый,
     фон значений: синий, текст значений: черный)

${BOLD}ВАЖНО:${RESET} Цвет фона и текста для одной колонки не должны совпадать!
EOF
}

# Очищаем экран
clear

# Заголовок
echo -e "${BOLD}${BG_BLACK}${TEXT_GREEN}PART 3: ВИЗУАЛЬНОЕ ОФОРМЛЕНИЕ${RESET}"
print_separator "="

# Проверка количества параметров
if ! check_params_count $# 4; then
    echo -e "\n${BOLD}❌ ОШИБКА: Требуется 4 параметра!${RESET}"
    show_help
    exit 1
fi

# Проверка, что все параметры - числа в диапазоне 1-6
for i in {1..4}; do
    param=${!i}
    if ! is_number_in_range "$param" 1 6; then
        log_error "Параметр $i должен быть числом от 1 до 6 (получено: $param)"
        show_help
        exit 1
    fi
done

# Присваиваем параметры
bg_names=$1      # фон названий
text_names=$2    # цвет текста названий
bg_values=$3     # фон значений
text_values=$4   # цвет текста значений

# Проверка на совпадение цветов
echo -e "\n${BOLD}🔍 ПРОВЕРКА ЦВЕТОВОЙ СХЕМЫ...${RESET}"

# Проверка для колонки названий
if ! check_colors_match "$bg_names" "$text_names"; then
    log_error "Цвет фона ($bg_names) и цвет текста ($text_names) для названий совпадают!"
    echo -e "${ITALIC}Названия будут нечитаемы. Пожалуйста, выберите разные цвета.${RESET}"
    exit 1
fi

# Проверка для колонки значений
if ! check_colors_match "$bg_values" "$text_values"; then
    log_error "Цвет фона ($bg_values) и цвет текста ($text_values) для значений совпадают!"
    echo -e "${ITALIC}Значения будут нечитаемы. Пожалуйста, выберите разные цвета.${RESET}"
    exit 1
fi

log_success "Цветовая схема корректна"

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

# Вывод использованной цветовой схемы
echo
print_separator "-"
echo -e "${BOLD}🎨 ИСПОЛЬЗОВАННАЯ ЦВЕТОВАЯ СХЕМА:${RESET}"
echo -e "Фон названий:       ${bg_names_code}   ${RESET} ($bg_names - $(get_color_name $bg_names))"
echo -e "Цвет названий:      ${text_names_code}ТЕКСТ${RESET} ($text_names - $(get_color_name $text_names))"
echo -e "Фон значений:       ${bg_values_code}   ${RESET} ($bg_values - $(get_color_name $bg_values))"
echo -e "Цвет значений:      ${text_values_code}ТЕКСТ${RESET} ($text_values - $(get_color_name $text_values))"
print_separator "-"

# Демонстрация всех доступных цветов
echo -e "\n${BOLD}📋 ДОСТУПНЫЕ ЦВЕТА:${RESET}"
for i in {1..6}; do
    bg=$(get_background_code "$i")
    text=$(get_text_color_code "$i")
    echo -e "${bg}${text} Цвет $i: $(get_color_name $i) ${RESET}"
done

# Вердикт
echo
free_percent=$(get_memory_status 2>/dev/null || echo 85)
echo -e "${ITALIC}$(memory_verdict "$free_percent")${RESET}"

exit 0
