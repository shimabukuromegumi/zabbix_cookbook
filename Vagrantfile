Vagrant.configure("2") do |config|

  config.vm.define :zabbix_t1 do |host|
    host.vm.box = "bento/centos-6.7"
    config.vm.network "private_network", ip: "192.168.33.11"
    config.vm.network :public_network,ip:"192.168.1.14",bridge:"en0: Wi-Fi (AirPort)"
    host.vm.synced_folder "./share_data", "/vagrant"
    host.vm.provider "virtualbox" do |v| 
      v.customize ["modifyvm", :id, "--memory", "1024"] 
      v.customize ["modifyvm", :id, "--cpus", "1"]
    end
  end

  config.ssh.insert_key = false
end
