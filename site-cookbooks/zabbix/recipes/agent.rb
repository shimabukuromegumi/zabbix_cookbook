
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
