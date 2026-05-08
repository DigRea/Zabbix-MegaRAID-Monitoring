## Zabbix Broadcom/LSI MegaRAID Monitoring

This solution has been tested on Broadcom/LSI MegaRAID SAS-3 3108 [Invader] (rev 02) and Broadcom/LSI MegaRAID Tri-Mode SAS3508 (rev 01) controllers, running on Debian 11 Bullseye (x86_64).

### Requirements

Requirements for the host to be monitored:
- zabbix-agent2 installed and configured.
- storcli utility (007.2705) installed.
- jq and git packages installed.

Requirements for the monitoring server:
- Zabbix server version: 7.4.9.
- In the configuration file **/etc/zabbix/zabbix_server.conf**, the **Timeout** value must be changed to **30** (the server will need to be restarted).

### Installation

Run the following commands on the host to be monitored:

```commandline
git clone https://github.com/DigRea/Zabbix-MegaRAID-Monitoring.git
cd Zabbix-MegaRAID-Monitoring/
chmod +x setup.sh
sudo ./setup.sh
```

### Links

Official Zabbix website (zabbix-agent2) - https://www.zabbix.com

Official Broadcom website (storcli) - https://docs.broadcom.com/docs/1232743397
