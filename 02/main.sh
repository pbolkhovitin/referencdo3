#!/bin/bash

# ==============================================
# PART 2: ИССЛЕДОВАНИЕ СИСТЕМЫ
# ==============================================
# Скрипт выводит информацию о системе и предлагает
# сохранить её в файл с именем ДД_ММ_ГГ_ЧЧ_ММ_СС.status
# ==============================================

# Подключаем библиотеки
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/system_info.sh"

# Очищаем экран
clear

# Заголовок
echo -e "${BOLD}${BG_BLACK}${TEXT_GREEN}PART 2: ИССЛЕДОВАНИЕ СИСТЕМЫ${RESET}"
print_separator "="

# Проверка на отсутствие параметров (скрипт должен запускаться без параметров)
if [[ $# -gt 0 ]]; then
    log_warning "Скрипт запускается без параметров. Лишние параметры будут проигнорированы."
    echo -e "Использование: $0"
    sleep 2
fi

# Сбор информации о системе
echo -e "\n${BOLD}${TEXT_BLUE}🔍 СБОР ИНФОРМАЦИИ О СИСТЕМЕ...${RESET}\n"

# Собираем данные
HOSTNAME=$(get_hostname)
TIMEZONE=$(get_timezone)
USER=$(get_current_user)
OS=$(get_os_info)
DATE=$(get_current_date)
UPTIME=$(get_uptime)
UPTIME_SEC=$(get_uptime_sec)
IP=$(get_ip)
MASK=$(get_netmask)
GATEWAY=$(get_gateway)
RAM_TOTAL=$(get_ram_total)
RAM_USED=$(get_ram_used)
RAM_FREE=$(get_ram_free)
SPACE_ROOT=$(get_root_space)
SPACE_ROOT_USED=$(get_root_space_used)
SPACE_ROOT_FREE=$(get_root_space_free)

# Формируем вывод
system_info=$(cat << EOF
${BOLD}${TEXT_CYAN}СИСТЕМНАЯ ИНФОРМАЦИЯ${RESET}
${BOLD}HOSTNAME${RESET} = ${TEXT_YELLOW}${HOSTNAME}${RESET}
${BOLD}TIMEZONE${RESET} = ${TEXT_YELLOW}${TIMEZONE}${RESET}
${BOLD}USER${RESET} = ${TEXT_YELLOW}${USER}${RESET}
${BOLD}OS${RESET} = ${TEXT_YELLOW}${OS}${RESET}
${BOLD}DATE${RESET} = ${TEXT_YELLOW}${DATE}${RESET}
${BOLD}UPTIME${RESET} = ${TEXT_YELLOW}${UPTIME}${RESET}
${BOLD}UPTIME_SEC${RESET} = ${TEXT_YELLOW}${UPTIME_SEC}${RESET}
${BOLD}IP${RESET} = ${TEXT_YELLOW}${IP}${RESET}
${BOLD}MASK${RESET} = ${TEXT_YELLOW}${MASK}${RESET}
${BOLD}GATEWAY${RESET} = ${TEXT_YELLOW}${GATEWAY}${RESET}
${BOLD}RAM_TOTAL${RESET} = ${TEXT_YELLOW}$(printf "%.3f" $RAM_TOTAL) GB${RESET}
${BOLD}RAM_USED${RESET} = ${TEXT_YELLOW}$(printf "%.3f" $RAM_USED) GB${RESET}
${BOLD}RAM_FREE${RESET} = ${TEXT_YELLOW}$(printf "%.3f" $RAM_FREE) GB${RESET}
${BOLD}SPACE_ROOT${RESET} = ${TEXT_YELLOW}$(printf "%.2f" $SPACE_ROOT) MB${RESET}
${BOLD}SPACE_ROOT_USED${RESET} = ${TEXT_YELLOW}$(printf "%.2f" $SPACE_ROOT_USED) MB${RESET}
${BOLD}SPACE_ROOT_FREE${RESET} = ${TEXT_YELLOW}$(printf "%.2f" $SPACE_ROOT_FREE) MB${RESET}
EOF
)

# Выводим на экран
echo "$system_info"
print_separator "-"

# Сохраняем версию без цветов для файла
plain_info=$(cat << EOF
HOSTNAME = ${HOSTNAME}
TIMEZONE = ${TIMEZONE}
USER = ${USER}
OS = ${OS}
DATE = ${DATE}
UPTIME = ${UPTIME}
UPTIME_SEC = ${UPTIME_SEC}
IP = ${IP}
MASK = ${MASK}
GATEWAY = ${GATEWAY}
RAM_TOTAL = $(printf "%.3f" $RAM_TOTAL) GB
RAM_USED = $(printf "%.3f" $RAM_USED) GB
RAM_FREE = $(printf "%.3f" $RAM_FREE) GB
SPACE_ROOT = $(printf "%.2f" $SPACE_ROOT) MB
SPACE_ROOT_USED = $(printf "%.2f" $SPACE_ROOT_USED) MB
SPACE_ROOT_FREE = $(printf "%.2f" $SPACE_ROOT_FREE) MB
EOF
)

# Спрашиваем о сохранении
echo
if confirm_action "💾 Записать данные в файл?"; then
    filename=$(date +"%d_%m_%y_%H_%M_%S").status
    echo "$plain_info" > "$filename"
    log_success "Информация сохранена в файл: ${BOLD}$filename${RESET}"
    echo -e "📁 Полный путь: ${ITALIC}$(pwd)/$filename${RESET}"
else
    log_info "Сохранение отменено пользователем"
fi

# Статистика
echo
print_separator "-"
echo -e "${ITALIC}Всего параметров: 16"
echo -e "Точность RAM: 3 знака после запятой"
echo -e "Точность SPACE: 2 знака после запятой${RESET}"

# Вердикт
echo
free_percent=$(get_memory_status 2>/dev/null || echo 85)
echo -e "${ITALIC}$(memory_verdict "$free_percent")${RESET}"

exit 0
