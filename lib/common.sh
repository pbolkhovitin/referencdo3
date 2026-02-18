#!/bin/bash

# ==============================================
# COMMON.SH - ОБЩАЯ БИБЛИОТЕКА ФУНКЦИЙ
# Linux Monitoring v1.0
# ==============================================

# ==============================================
# 1. ЦВЕТА И ФОРМАТИРОВАНИЕ
# ==============================================

# Цвета текста
readonly TEXT_WHITE='\033[37m'
readonly TEXT_RED='\033[31m'
readonly TEXT_GREEN='\033[32m'
readonly TEXT_BLUE='\033[34m'
readonly TEXT_PURPLE='\033[35m'
readonly TEXT_BLACK='\033[30m'

# Цвета фона
readonly BG_WHITE='\033[47m'
readonly BG_RED='\033[41m'
readonly BG_GREEN='\033[42m'
readonly BG_BLUE='\033[44m'
readonly BG_PURPLE='\033[45m'
readonly BG_BLACK='\033[40m'

# Стили
readonly RESET='\033[0m'
readonly BOLD='\033[1m'
readonly ITALIC='\033[3m'
readonly UNDERLINE='\033[4m'
readonly BLINK='\033[5m'
readonly REVERSE='\033[7m'

# Массивы для преобразования номеров цветов
COLOR_NAMES=("white" "red" "green" "blue" "purple" "black")
COLOR_BG=("$BG_WHITE" "$BG_RED" "$BG_GREEN" "$BG_BLUE" "$BG_PURPLE" "$BG_BLACK")
COLOR_TEXT=("$TEXT_WHITE" "$TEXT_RED" "$TEXT_GREEN" "$TEXT_BLUE" "$TEXT_PURPLE" "$TEXT_BLACK")

# ==============================================
# 2. ФУНКЦИИ ДЛЯ РАБОТЫ С ЦВЕТАМИ
# ==============================================

# Получить код цвета фона по номеру
get_background_code() {
    local color_num=$1
    if [[ $color_num -ge 1 && $color_num -le 6 ]]; then
        echo "${COLOR_BG[$((color_num-1))]}"
    else
        echo "$RESET"
    fi
}

# Получить код цвета текста по номеру
get_text_color_code() {
    local color_num=$1
    if [[ $color_num -ge 1 && $color_num -le 6 ]]; then
        echo "${COLOR_TEXT[$((color_num-1))]}"
    else
        echo "$RESET"
    fi
}

# Получить название цвета по номеру
get_color_name() {
    local color_num=$1
    if [[ $color_num -ge 1 && $color_num -le 6 ]]; then
        echo "${COLOR_NAMES[$((color_num-1))]}"
    else
        echo "unknown"
    fi
}

# Проверка совпадения цветов фона и текста
check_colors_match() {
    local bg=$1
    local text=$2

    if [[ $bg -eq $text ]]; then
        return 1  # Цвета совпадают - ошибка
    fi
    return 0  # Цвета разные - ок
}

# Применить цвета к строке
colorize() {
    local bg_code=$1
    local text_code=$2
    local string=$3

    echo -e "${bg_code}${text_code}${string}${RESET}"
}

# ==============================================
# 3. ФУНКЦИИ ВАЛИДАЦИИ
# ==============================================

# Проверка, является ли аргумент числом
is_number() {
    [[ $1 =~ ^[0-9]+$ ]]
}

# Проверка, является ли аргумент числом в диапазоне
is_number_in_range() {
    local num=$1
    local min=$2
    local max=$3

    if is_number "$num" && [[ $num -ge $min && $num -le $max ]]; then
        return 0
    fi
    return 1
}

# Проверка количества параметров
check_params_count() {
    local actual=$1
    local expected=$2

    if [[ $actual -ne $expected ]]; then
        echo "Ошибка: Неверное количество параметров"
        echo "Ожидалось: $expected, получено: $actual"
        return 1
    fi
    return 0
}

# Проверка существования директории
check_directory() {
    local dir=$1

    if [[ ! -d "$dir" ]]; then
        echo "Ошибка: Директория '$dir' не существует"
        return 1
    fi

    if [[ ! -r "$dir" ]]; then
        echo "Ошибка: Нет прав на чтение директории '$dir'"
        return 1
    fi

    return 0
}

# Проверка, заканчивается ли путь на '/'
check_path_ends_with_slash() {
    local path=$1

    if [[ "$path" != */ ]]; then
        echo "Ошибка: Путь должен заканчиваться на '/'"
        return 1
    fi
    return 0
}

# ==============================================
# 4. ФУНКЦИИ ФОРМАТИРОВАНИЯ ВЫВОДА
# ==============================================

# Форматирование байт в читаемый вид
format_bytes() {
    local bytes=$1
    local precision=${2:-2}

    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes} B"
    elif [[ $bytes -lt 1048576 ]]; then
        echo "$(echo "scale=$precision; $bytes/1024" | bc) KB"
    elif [[ $bytes -lt 1073741824 ]]; then
        echo "$(echo "scale=$precision; $bytes/1048576" | bc) MB"
    else
        echo "$(echo "scale=$precision; $bytes/1073741824" | bc) GB"
    fi
}

# Форматирование с точностью
format_with_precision() {
    local value=$1
    local precision=$2
    printf "%.${precision}f" "$value"
}

# Создание разделителя
print_separator() {
    local char=${1:-'-'}
    local length=${2:-50}
    printf '%*s\n' "$length" '' | tr ' ' "$char"
}

# ==============================================
# 5. ФУНКЦИИ РАБОТЫ С ФАЙЛАМИ
# ==============================================

# Сохранение вывода в файл
save_to_file() {
    local content=$1
    local filename=${2:-$(date +"%d_%m_%y_%H_%M_%S").status}

    echo "$content" > "$filename"
    echo "Информация сохранена в файл: $filename"
}

# Чтение конфигурационного файла
read_config_file() {
    local config_file=$1
    local -n config_ref=$2  # передача по ссылке (ассоциативный массив)

    if [[ ! -f "$config_file" ]]; then
        return 1
    fi

    while IFS='=' read -r key value; do
        # Пропускаем комментарии и пустые строки
        [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue

        # Убираем пробелы
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)

        # Сохраняем в ассоциативный массив
        config_ref["$key"]="$value"
    done < "$config_file"

    return 0
}

# ==============================================
# 6. ФУНКЦИИ ЛОГГИРОВАНИЯ И ОТЛАДКИ
# ==============================================

# Логирование ошибок
log_error() {
    echo -e "${BG_RED}${TEXT_WHITE}[ОШИБКА]${RESET} $1" >&2
}

# Логирование предупреждений
log_warning() {
    echo -e "${BG_PURPLE}${TEXT_WHITE}[ПРЕДУПРЕЖДЕНИЕ]${RESET} $1"
}

# Логирование информации
log_info() {
    echo -e "${BG_GREEN}${TEXT_BLACK}[ИНФО]${RESET} $1"
}

# Логирование успеха
log_success() {
    echo -e "${BG_GREEN}${TEXT_BLACK}[УСПЕХ]${RESET} $1"
}

# ==============================================
# 7. ФУНКЦИИ ДЛЯ ИЗМЕРЕНИЯ ВРЕМЕНИ
# ==============================================

# Начать измерение времени
start_timer() {
    _start_time=$(date +%s.%N)
}

# Закончить измерение и получить результат
end_timer() {
    local end_time=$(date +%s.%N)
    local elapsed=$(echo "$end_time - $_start_time" | bc)
    echo "$elapsed"
}

# Форматировать время выполнения
format_execution_time() {
    local seconds=$1
    printf "%.2f" "$seconds"
}

# ==============================================
# 8. ФУНКЦИИ ДЛЯ РАБОТЫ С ПОЛЬЗОВАТЕЛЕМ
# ==============================================

# Запрос подтверждения (Y/N)
confirm_action() {
    local prompt=${1:-"Продолжить?"}
    local response

    echo -n "$prompt (Y/N): "
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Чтение параметров с проверкой
read_param_with_check() {
    local prompt=$1
    local check_function=$2
    local error_message=$3
    local value

    while true; do
        echo -n "$prompt"
        read -r value

        if eval "$check_function \"$value\""; then
            echo "$value"
            return 0
        else
            log_error "$error_message"
        fi
    done
}

# ==============================================
# 9. ФУНКЦИИ ОБРАБОТКИ ОШИБОК
# ==============================================

# Общий обработчик ошибок
error_exit() {
    local message=$1
    local exit_code=${2:-1}

    log_error "$message"
    exit "$exit_code"
}

# Проверка кода возврата
check_return_code() {
    local code=$?
    local message=$1

    if [[ $code -ne 0 ]]; then
        error_exit "$message (код: $code)" "$code"
    fi
}

# ==============================================
# 10. ФУНКЦИИ ДЛЯ ТЕСТИРОВАНИЯ
# ==============================================

# Простой assert для тестов
assert() {
    local condition=$1
    local message=$2

    if eval "$condition"; then
        echo "✓ $message"
        return 0
    else
        echo "✗ $message"
        return 1
    fi
}

# ==============================================
# ЭКСПОРТ ФУНКЦИЙ
# ==============================================

# Экспортируем все функции для использования в дочерних скриптах
export -f get_background_code get_text_color_code get_color_name
export -f check_colors_match colorize
export -f is_number is_number_in_range check_params_count
export -f check_directory check_path_ends_with_slash
export -f format_bytes format_with_precision print_separator
export -f save_to_file read_config_file
export -f log_error log_warning log_info log_success
export -f start_timer end_timer format_execution_time
export -f confirm_action read_param_with_check
export -f error_exit check_return_code
export -f assert

# Сообщение об успешной загрузке
echo -e "${BG_GREEN}${TEXT_BLACK}✓ common.sh загружен${RESET}" >&2
