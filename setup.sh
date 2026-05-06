#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[*]${NC} $1"
}

# Проверка прав root
if [[ $EUID -ne 0 ]]; then
    print_error "Этот скрипт должен запускаться с правами root"
    echo "Используйте: sudo ./setup.sh"
    exit 1
fi

# Проверка существования необходимых файлов
print_status "Проверка наличия необходимых файлов..."

if [[ ! -f "zabbix-storcli" ]]; then
    print_error "Файл zabbix-storcli не найден в текущей директории"
    exit 1
fi

if [[ ! -d "scripts" ]]; then
    print_error "Каталог scripts не найден в текущей директории"
    exit 1
fi

if [[ ! -f "megaraid.conf" ]]; then
    print_error "Файл megaraid.conf не найден в текущей директории"
    exit 1
fi

# 1. Копирование файла zabbix-storcli в /etc/sudoers.d/
print_status "Копирование zabbix-storcli в /etc/sudoers.d/..."
cp "zabbix-storcli" /etc/sudoers.d/
if [[ $? -eq 0 ]]; then
    chmod 440 /etc/sudoers.d/zabbix-storcli
    print_status "Файл успешно скопирован и защищен (права 440)"
else
    print_error "Ошибка при копировании zabbix-storcli"
    exit 1
fi

# 2. Копирование директории scripts в /usr/local/bin/zabbix/
TARGET_SCRIPTS_DIR="/usr/local/bin/zabbix/scripts"
print_status "Копирование скриптов в ${TARGET_SCRIPTS_DIR}..."

mkdir -p "${TARGET_SCRIPTS_DIR}"
if [[ $? -ne 0 ]]; then
    print_error "Не удалось создать директорию ${TARGET_SCRIPTS_DIR}"
    exit 1
fi

# Копируем все скрипты из локальной директории scripts
cp -f scripts/raid_* "${TARGET_SCRIPTS_DIR}/" 2>/dev/null
if [[ $? -eq 0 ]]; then
    # Даем права на исполнение всем скриптам raid*
    chmod +x ${TARGET_SCRIPTS_DIR}/raid_*
    print_status "Скрипты скопированы и им выданы права на исполнение"
else
    print_warning "Не удалось скопировать некоторые скрипты (возможно, их нет)"
fi

# Проверяем наличие скриптов после копирования
print_status "Установленные скрипты:"
ls -la ${TARGET_SCRIPTS_DIR}/raid_* 2>/dev/null || print_warning "Скрипты не найдены"

# 3. Копирование файла megaraid.conf в /etc/zabbix/zabbix_agent2.d/
ZABBIX_CONF_DIR="/etc/zabbix/zabbix_agent2.d"
print_status "Копирование megaraid.conf в ${ZABBIX_CONF_DIR}..."

# Проверяем существование директории Zabbix
if [[ ! -d "${ZABBIX_CONF_DIR}" ]]; then
    print_error "Директория ${ZABBIX_CONF_DIR} не существует. Установлен ли Zabbix-Agent2?"
    exit 1
fi

cp "megaraid.conf" "${ZABBIX_CONF_DIR}/"
if [[ $? -eq 0 ]]; then
    chmod 644 "${ZABBIX_CONF_DIR}/megaraid.conf"
    print_status "Файл конфигурации успешно скопирован"
else
    print_error "Ошибка при копировании megaraid.conf"
    exit 1
fi

# 4. Перезапуск сервиса zabbix-agent2
print_status "Перезапуск сервиса zabbix-agent2..."

# Проверяем, установлен ли сервис
if ! systemctl list-unit-files | grep -q "zabbix-agent2.service"; then
    print_error "Сервис zabbix-agent2 не найден в системе"
    exit 1
fi

# Перезапускаем сервис с полным именем .service (Debian 11 и другие системы)
systemctl restart zabbix-agent2.service
if [[ $? -eq 0 ]]; then
    print_status "Сервис zabbix-agent2 успешно перезапущен"
    
    # Показываем статус сервиса
    print_status "Статус сервиса:"
    systemctl status zabbix-agent2.service --no-pager -l
else
    print_error "Ошибка при перезапуске zabbix-agent2.service"
    exit 1
fi

print_status "============================"
print_status "Установка завершена успешно!"
print_status "============================"

exit 0
