## Zabbix Broadcom/LSI MegaRAID Monitoring

Данное решение было протестировано на контроллерах Broadcom/LSI MegaRAID SAS-3 3108 [Invader] (rev 02), Broadcom/LSI MegaRAID Tri-Mode SAS3508 (rev 01) и операционной системе Debian 11 Bullseye (x86_64). Версия сервера Zabbix - 7.4.9, версия утилиты StorCLI - 007.2705.

Скачать и установить утилиту StorCLI можно с официального сайта - https://docs.broadcom.com/docs/1232743397. Для того, чтобы StorCLI можно было запускать от пользователя zabbix, необходимо скопировать файл **zabbix-storcli** в **/etc/sudoers.d/**.

