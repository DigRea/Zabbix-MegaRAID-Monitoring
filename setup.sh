#!/bin/bash

# Скрипт установки Zabbix MegaRAID Monitoring
# Запускать из текущего каталога (где находится сам скрипт)

set -e  # Прерывать выполнение при любой ошибке

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Проверка, что скрипт запущен с правами root
if [[ $EUID -ne 0 ]]; then
    log_error "Этот скрипт должен запускаться с правами root (sudo)"
    echo "Пожалуйста, запустите: sudo ./setup.sh"
    exit 1
fi

# Определение текущей директории
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log_info "Текущая директория: $SCRIPT_DIR"

# Проверка существования необходимых файлов и директорий
check_requirements() {
    log_info "Проверка необходимых файлов..."
    
    if [[ ! -f "$SCRIPT_DIR/zabbix-storcli" ]]; then
        log_error "Файл zabbix-storcli не найден в текущей директории"
        exit 1
    fi
    
    if [[ ! -d "$SCRIPT_DIR/scripts" ]]; then
        log_error "Директория scripts не найдена в текущей директории"
        exit 1
    fi
    
    if [[ ! -f "$SCRIPT_DIR/megaraid.conf" ]]; then
        log_error "Файл megaraid.conf не найден в текущей директории"
        exit 1
    fi
    
    log_info "Все необходимые файлы найдены"
}

# Копирование файла zabbix-storcli в /etc/sudoers.d/
copy_sudoers_file() {
    log_info "Копирование zabbix-storcli в /etc/sudoers.d/..."
    
    DEST_SUDOERS="/etc/sudoers.d/zabbix-storcli"
    
    # Копируем файл
    cp "$SCRIPT_DIR/zabbix-storcli" "$DEST_SUDOERS"
    
    # Устанавливаем правильные права (sudoers.d требует права 440)
    chmod 440 "$DEST_SUDOERS"
    
    # Проверяем синтаксис sudoers
    if visudo -c -f "$DEST_SUDOERS" 2>/dev/null; then
        log_info "Файл успешно скопирован в $DEST_SUDOERS"
    else
        log_error "Ошибка в синтаксисе файла sudoers"
        rm -f "$DEST_SUDOERS"
        exit 1
    fi
}

# Копирование директории scripts в /usr/local/lib/
copy_scripts() {
    log_info "Копирование директории scripts в /usr/local/lib/..."
    
    DEST_SCRIPTS="/usr/local/lib/scripts"
    
    # Удаляем старую директорию, если существует
    if [[ -d "$DEST_SCRIPTS" ]]; then
        log_warn "Директория $DEST_SCRIPTS уже существует. Удаляем..."
        rm -rf "$DEST_SCRIPTS"
    fi
    
    # Копируем директорию
    cp -r "$SCRIPT_DIR/scripts" "$DEST_SCRIPTS"
    
    # Даем права на исполнение всем .sh файлам
    find "$DEST_SCRIPTS" -name "*.sh" -exec chmod +x {} \;
    
    log_info "Скрипты скопированы в $DEST_SCRIPTS и им выданы права на исполнение"
}

# Копирование конфигурационного файла
copy_config() {
    log_info "Копирование megaraid.conf в /etc/zabbix/zabbix.conf.d/..."
    
    DEST_CONFIG="/etc/zabbix/zabbix.conf.d/megaraid.conf"
    CONFIG_DIR="/etc/zabbix/zabbix.conf.d"
    
    # Создаем директорию, если она не существует
    if [[ ! -d "$CONFIG_DIR" ]]; then
        log_warn "Директория $CONFIG_DIR не существует. Создаем..."
        mkdir -p "$CONFIG_DIR"
    fi
    
    # Копируем файл
    cp "$SCRIPT_DIR/megaraid.conf" "$DEST_CONFIG"
    
    # Устанавливаем права
    chmod 644 "$DEST_CONFIG"
    
    log_info "Файл конфигурации скопирован в $DEST_CONFIG"
}

# Перезапуск Zabbix Agent 2
restart_zabbix_agent() {
    log_info "Перезапуск сервиса zabbix-agent2..."
    
    # Проверяем, какой init system используется
    if systemctl list-units --type=service | grep -q zabbix-agent2; then
        # systemd
        systemctl restart zabbix-agent2
        if systemctl is-active --quiet zabbix-agent2; then
            log_info "Сервис zabbix-agent2 успешно перезапущен"
        else
            log_error "Не удалось перезапустить zabbix-agent2"
            exit 1
        fi
    elif service zabbix-agent2 status &>/dev/null; then
        # sysvinit
        service zabbix-agent2 restart
        log_info "Сервис zabbix-agent2 перезапущен (sysvinit)"
    else
        log_warn "Сервис zabbix-agent2 не найден. Пожалуйста, перезапустите его вручную"
    fi
}

# Проверка установки storcli (опционально)
check_storcli() {
    if command -v storcli &>/dev/null; then
        log_info "storcli найден: $(which storcli)"
    else
        log_warn "storcli не найден в системе. Убедитесь, что StorCLI установлен"
        log_warn "Вы можете установить его из официального репозитория Broadcom"
    fi
}

# Основная функция
main() {
    log_info "=== Начало установки Zabbix MegaRAID Monitoring ==="
    
    check_requirements
    copy_sudoers_file
    copy_scripts
    copy_config
    check_storcli
    restart_zabbix_agent
    
    log_info "=== Установка завершена успешно ==="
    echo ""
    echo "Проверьте работу мониторинга следующими командами:"
    echo "  sudo /usr/local/lib/scripts/raid_cv-bbu_status.sh"
    echo "  sudo /usr/local/lib/scripts/raid_disk_health.sh"
    echo "  sudo /usr/local/lib/scripts/raid_pdisk_status.sh"
    echo "  sudo /usr/local/lib/scripts/raid_vdisk_status.sh"
    echo ""
    echo "Логи Zabbix Agent: journalctl -u zabbix-agent2 -f"
}

# Запуск основной функции
main
