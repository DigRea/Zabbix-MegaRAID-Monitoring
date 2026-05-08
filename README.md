## Zabbix Broadcom/LSI MegaRAID Monitoring

Данное решение было протестировано на контроллерах Broadcom/LSI MegaRAID SAS-3 3108 [Invader] (rev 02), Broadcom/LSI MegaRAID Tri-Mode SAS3508 (rev 01) и операционной системе Debian 11 Bullseye (x86_64). Версия сервера Zabbix - 7.4.9.

### Требования

Необходимые требования к хосту, который планируем мониторить:
- установлен и настроен zabbix-agent2.
- установлена утилита storcli (007.2705).
- установлены пакеты jq и git.

Необходимые требования к серверу мониторинга:
- версия сервера Zabbix - 7.4.9.
- в конфигурационном файле **/etc/zabbix/zabbix_server.conf** значение **Timeout** изменено на 30 (необходимо будет перезапустить сервер).

### Установка

Выполняем на хосте, который планируем мониторить:
```commandline
git clone https://github.com/DigRea/Zabbix-MegaRAID-Monitoring.git
cd Zabbix-MegaRAID-Monitoring/
chmod +x setup.sh
sudo ./setup.sh
```
### Ссылки

Официальный сайт Zabbix (zabbix-agent2) - https://www.zabbix.com. 
Официальный сайт Broadcom (storcli) - https://docs.broadcom.com/docs/1232743397.
