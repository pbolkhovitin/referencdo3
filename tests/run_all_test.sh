#!/bin/bash

# ==============================================
# test_all.sh - Скрипт для автоматического тестирования
# ==============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/src/lib/common.sh"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0
TOTAL=0

print_test_result() {
    local test_name=$1
    local result=$2
    local message=$3

    if [[ $result -eq 0 ]]; then
        echo -e "${GREEN}✓ PASS${NC} $test_name"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC} $test_name"
        [[ -n "$message" ]] && echo "  └─ $message"
        ((FAILED++))
    fi
    ((TOTAL++))
}

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}   ТЕСТИРОВАНИЕ LINUX MONITORING v1.0  ${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# Part 1 Tests
echo -e "${YELLOW}[PART 1] Проба пера${NC}"
"$SCRIPT_DIR/src/01/main.sh" "test" > /dev/null 2>&1
print_test_result "Part 1: Текстовый параметр" $?

"$SCRIPT_DIR/src/01/main.sh" "123" > /dev/null 2>&1
[[ $? -eq 1 ]] && res=0 || res=1
print_test_result "Part 1: Числовой параметр (должна быть ошибка)" $res

"$SCRIPT_DIR/src/01/main.sh" > /dev/null 2>&1
[[ $? -eq 1 ]] && res=0 || res=1
print_test_result "Part 1: Без параметров (должна быть ошибка)" $res
echo

# Part 2 Tests
echo -e "${YELLOW}[PART 2] Исследование системы${NC}"
output=$("$SCRIPT_DIR/src/02/main.sh" <<< "N" | grep -c "HOSTNAME")
[[ $output -gt 0 ]] && res=0 || res=1
print_test_result "Part 2: Вывод информации" $res

"$SCRIPT_DIR/src/02/main.sh" <<< "Y" > /dev/null 2>&1
status_file=$(ls -t *.status 2>/dev/null | head -1)
[[ -f "$status_file" ]] && res=0 || res=1
print_test_result "Part 2: Сохранение в файл" $res
[[ -f "$status_file" ]] && rm "$status_file"
echo

# Part 3 Tests
echo -e "${YELLOW}[PART 3] Визуальное оформление${NC}"
"$SCRIPT_DIR/src/03/main.sh" 1 2 3 4 > /dev/null 2>&1
print_test_result "Part 3: Корректные параметры" $?

"$SCRIPT_DIR/src/03/main.sh" 1 1 3 4 > /dev/null 2>&1
[[ $? -eq 1 ]] && res=0 || res=1
print_test_result "Part 3: Совпадающие цвета (должна быть ошибка)" $res

"$SCRIPT_DIR/src/03/main.sh" 1 2 3 > /dev/null 2>&1
[[ $? -eq 1 ]] && res=0 || res=1
print_test_result "Part 3: Недостаточно параметров" $res
echo

# Part 4 Tests
echo -e "${YELLOW}[PART 4] Конфигурирование цветов${NC}"
# Создаем тестовый конфиг
cat > "$SCRIPT_DIR/src/04/test_config.cfg" << EOF
column1_background=2
column1_font_color=4
column2_background=5
column2_font_color=1
EOF

mv "$SCRIPT_DIR/src/04/config.cfg" "$SCRIPT_DIR/src/04/config.cfg.bak" 2>/dev/null
cp "$SCRIPT_DIR/src/04/test_config.cfg" "$SCRIPT_DIR/src/04/config.cfg"

output=$("$SCRIPT_DIR/src/04/main.sh" | grep -c "Column 1 background = 2")
[[ $output -gt 0 ]] && res=0 || res=1
print_test_result "Part 4: Загрузка из конфига" $res

rm "$SCRIPT_DIR/src/04/config.cfg"
output=$("$SCRIPT_DIR/src/04/main.sh" | grep -c "default")
[[ $output -gt 0 ]] && res=0 || res=1
print_test_result "Part 4: Значения по умолчанию" $res

# Восстанавливаем оригинальный конфиг
mv "$SCRIPT_DIR/src/04/config.cfg.bak" "$SCRIPT_DIR/src/04/config.cfg" 2>/dev/null
rm "$SCRIPT_DIR/src/04/test_config.cfg" 2>/dev/null
echo

# Part 5 Tests
echo -e "${YELLOW}[PART 5] Исследование файловой системы${NC}"
"$SCRIPT_DIR/src/05/main.sh" "/tmp/" > /dev/null 2>&1
print_test_result "Part 5: Корректный путь" $?

"$SCRIPT_DIR/src/05/main.sh" "/tmp" > /dev/null 2>&1
[[ $? -eq 1 ]] && res=0 || res=1
print_test_result "Part 5: Путь без '/' (должна быть ошибка)" $res

"$SCRIPT_DIR/src/05/main.sh" > /dev/null 2>&1
[[ $? -eq 1 ]] && res=0 || res=1
print_test_result "Part 5: Без параметров" $res
echo

# Итоговый результат
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}ИТОГИ ТЕСТИРОВАНИЯ${NC}"
echo -e "${GREEN}Пройдено: $PASSED${NC}"
echo -e "${RED}Провалено: $FAILED${NC}"
echo -e "${YELLOW}Всего: $TOTAL${NC}"
echo -e "${YELLOW}========================================${NC}"

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ ВСЕ ТЕСТЫ ПРОЙДЕНЫ УСПЕШНО${NC}"
    exit 0
else
    echo -e "${RED}❌ ОБНАРУЖЕНЫ ОШИБКИ${NC}"
    exit 1
fi
