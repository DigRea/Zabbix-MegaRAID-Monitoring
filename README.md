## Zabbix Broadcom/LSI MegaRAID Monitoring

Данное решение было протестировано на контроллерах Broadcom/LSI MegaRAID SAS-3 3108 [Invader] (rev 02), Broadcom/LSI MegaRAID Tri-Mode SAS3508 (rev 01) и операционной системе Debian 11 Bullseye (x86_64). Версия сервера Zabbix - 7.4.9, версия утилиты StorCLI - 007.2705.

Скачать и установить утилиту StorCLI можно с официального сайта - https://docs.broadcom.com/docs/1232743397.

1. Скачать с GitHub проект.
2. Запустить скрипт setup.sh
   - скопировать файл zabiix-storcli в /etc.sudoers.d/
   - скопировать директорию scripts в /usr/local/lib/ и дать права на исполнение (chmod +x)
   - скопировать файл megaraid.conf в /etc/zabbix/zabbix.conf.d/
