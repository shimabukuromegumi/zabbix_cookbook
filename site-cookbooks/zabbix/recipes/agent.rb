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

%w{zabbix zabbix-agent zabbix-sender}.each do |pkg|
  package pkg do
    action :install
  end
end

template '/etc/zabbix/zabbix_agentd.conf' do
  source 'zabbix_agentd.conf.erb'
  owner  'root'
  group  'root'
  mode   '0640'
  action :create
  notifies :run, 'bash[restart_ZabbixAgent]'
end

bash 'restart_ZabbixAgent' do
  code <<-EOF
    ps -ef | grep -v grep | grep -q zabbix_agentd
    [ $? -eq 0 ] && service zabbix-agent restart || service zabbix-agent start
    chkconfig zabbix-agent on
  EOF
  action :nothing
end
