## Zabbix Broadcom/LSI MegaRAID Monitoring

Данное решение было протестировано на контроллерах Broadcom/LSI MegaRAID SAS-3 3108 [Invader] (rev 02), Broadcom/LSI MegaRAID Tri-Mode SAS3508 (rev 01) и операционной системе Debian 11 Bullseye (x86_64). Версия сервера Zabbix - 7.4.9.

Подразумевается, что на сервере (хосте), который планируется мониторить, уже установлен и настроен zabbix-agent2 и StorCLI (версия 007.2705). Скачать и установить zabbix-agent2 можно с официального сайта Zabbix - https://www.zabbix.com. Скачать утилиту StorCLI можно с официального сайта Broadcom - https://docs.broadcom.com/docs/1232743397.

Клонируем репозиторий с **GitHub** (установив предварительно пакет **git**):
```commandline
git clone https://github.com/DigRea/Zabbix-MegaRAID-Monitoring.git
```
Заходим в директорию проекта:
```commandline
cd Zabbix-MegaRAID-Monitoring/
```
Даём права на исполнение скрипта:
```commandline
chmod +x setup.sh
```
Запускаем скрипт от суперпользователя:
```commandline
sudo ./setup.sh
```
