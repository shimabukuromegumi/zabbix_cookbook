default['zabbix']['server']['pkgs'] = %w(
  mysql-server fping iksemel net-snmp net-snmp-libs net-snmp-utils openldap curl unixODBC
  OpenIPMI-libs OpenIPMI-tools libssh2 unzip httpd mod_ssl php php-bcmath
  php-gd php-mbstring php-mysql php-xml vlgothic-p-fonts traceroute nmap
  zabbix zabbix-server zabbix-server-mysql zabbix-web zabbix-web-mysql
  zabbix-web-japanese zabbix-get
)

default['zabbix']['agent']['pkgs'] = %w(
)
