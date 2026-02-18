#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# ==============================================
# ЦВЕТОВЫЕ СХЕМЫ ДЛЯ ВЫВОДА
# ==============================================

# Цвета по умолчанию (если не указаны в конфиге)
declare -A DEFAULT_COLORS=(
    ["column1_background"]=1  # white
    ["column1_font_color"]=2  # red
    ["column2_background"]=3  # green
    ["column2_font_color"]=4  # blue
)

# Загрузка цветов из конфига
load_color_scheme() {
    local config_file=$1
    local -n colors_ref=$2

    # Устанавливаем значения по умолчанию
    for key in "${!DEFAULT_COLORS[@]}"; do
        colors_ref["$key"]="${DEFAULT_COLORS[$key]}"
    done

    # Если конфиг существует, читаем его
    if [[ -f "$config_file" ]]; then
        declare -A config_values
        read_config_file "$config_file" config_values

        # Переопределяем значения из конфига
        for key in "${!config_values[@]}"; do
            if [[ -n "${colors_ref[$key]}" ]]; then
                colors_ref["$key"]="${config_values[$key]}"
            fi
        done
    fi
}

# Проверка цветовой схемы на корректность
validate_color_scheme() {
    local -n colors_ref=$1

    # Проверка column1
    if ! check_colors_match "${colors_ref[column1_background]}" "${colors_ref[column1_font_color]}"; then
        log_error "Цвета фона и текста для колонки 1 совпадают"
        return 1
    fi

    # Проверка column2
    if ! check_colors_match "${colors_ref[column2_background]}" "${colors_ref[column2_font_color]}"; then
        log_error "Цвета фона и текста для колонки 2 совпадают"
        return 1
    fi

    return 0
}

# Применение цветовой схемы к строке с двумя колонками
apply_color_scheme() {
    local -n colors_ref=$1
    local label=$2
    local value=$3

    local bg1=$(get_background_code "${colors_ref[column1_background]}")
    local text1=$(get_text_color_code "${colors_ref[column1_font_color]}")
    local bg2=$(get_background_code "${colors_ref[column2_background]}")
    local text2=$(get_text_color_code "${colors_ref[column2_font_color]}")

    echo -e "${bg1}${text1}${label}${RESET} = ${bg2}${text2}${value}${RESET}"
}

# Вывод цветовой схемы в отчёте
print_color_scheme_report() {
    local -n colors_ref=$1
    local config_used=$2

    echo
    if [[ "$config_used" == "default" ]]; then
        echo "Column 1 background = default ($(get_color_name "${colors_ref[column1_background]}"))"
        echo "Column 1 font color = default ($(get_color_name "${colors_ref[column1_font_color]}"))"
        echo "Column 2 background = default ($(get_color_name "${colors_ref[column2_background]}"))"
        echo "Column 2 font color = default ($(get_color_name "${colors_ref[column2_font_color]}"))"
    else
        echo "Column 1 background = ${colors_ref[column1_background]} ($(get_color_name "${colors_ref[column1_background]}"))"
        echo "Column 1 font color = ${colors_ref[column1_font_color]} ($(get_color_name "${colors_ref[column1_font_color]}"))"
        echo "Column 2 background = ${colors_ref[column2_background]} ($(get_color_name "${colors_ref[column2_background]}"))"
        echo "Column 2 font color = ${colors_ref[column2_font_color]} ($(get_color_name "${colors_ref[column2_font_color]}"))"
    fi
}

# Экспорт функций
export -f load_color_scheme validate_color_scheme apply_color_scheme print_color_scheme_report
