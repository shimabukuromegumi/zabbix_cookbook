#
# Cookbook Name:: zabbix
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Download Directory
directory "/usr/local/src/zabbix" do
  owner 'root'
  group 'root'
  mode  '0755'
  recursive true
end

# Zabbix archive download
remote_file "/usr/local/src/zabbix/zabbix-release-2.4-1.el6.noarch.rpm" do
  source "http://repo.zabbix.com/zabbix/2.4/rhel/6/x86_64/zabbix-release-2.4-1.el6.noarch.rpm"
  action :create_if_missing
end

bash 'install_zabbix-release' do
  user 'root'
  code <<-EOH
    rpm -ivh /usr/local/src/zabbix/zabbix-release-2.4-1.el6.noarch.rpm
  EOH
  not_if 'test `rpm -qa zabbix-release | wc -l` -ge 1'
end

node['zabbix']['server']['pkgs'].each do |pkg|
  package pkg do
    action :install
  end
end

service 'mysqld' do
  action [:enable, :start]
end

bash "settings_zabbixdb" do
  code <<-EOH
    echo "create database zabbix character set utf8 collate utf8_bin; grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';" | mysql -uroot -A
    cd $(ls -1dr /usr/share/doc/zabbix-server-mysql-* | head -1)/create
    mysql -uroot -A zabbix < schema.sql
    mysql -uroot -A zabbix < images.sql
    mysql -uroot -A zabbix < data.sql
    echo "ALTER TABLE events ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;" | mysql -uroot -A zabbix
    echo "ALTER TABLE history ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;" | mysql -uroot -A zabbix
    echo "ALTER TABLE history_log ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;" | mysql -uroot -A zabbix
    echo "ALTER TABLE history_str ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;" | mysql -uroot -A zabbix
    echo "ALTER TABLE history_text ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;" | mysql -uroot -A zabbix
    echo "ALTER TABLE history_uint ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;" | mysql -uroot -A zabbix
  EOH
end

template '/etc/zabbix/zabbix_server.conf' do
  source 'zabbix_server.conf.erb'
  owner 'root'
  group 'root'
  mode  '0640'
  action :create
end

service 'zabbix-server' do
  action [:enable, :start]
end

template '/etc/httpd/conf.d/zabbix.conf' do
  source 'zabbix.conf.erb'
  owner  'root'
  group  'root'
  mode   '0644'
  action :create
end

template '/etc/httpd/conf/httpd.conf' do
  source 'httpd.conf.erb'
  owner 'root'
  group 'root'
  mode  '0644'
  action :create
end

service 'httpd' do
  action [:enable, :start]
end

template '/etc/zabbix/web/zabbix.conf.php' do
  source 'zabbix.conf.php.erb'
  owner  'apache'
  group  'apache'
  mode   '0644'
  action :create
end

cookbook_file '/var/www/html/index.html' do
  source 'index.html'
  owner  'root'
  group  'root'
  mode   '0644'
end
