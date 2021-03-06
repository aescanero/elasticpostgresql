# -*- mode: ruby -*-

VAGRANTFILE_API_VERSION = "2"

require 'yaml'

# Read YAML file with box details
servers = YAML.load_file('servers.yaml')

# Create boxes
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.ssh.insert_key = false
  config.ssh.username = "ubuntu"
  # Iterate through entries in YAML file
  servers.each do |servers|
    config.vm.define servers["name"] do |srv|
      servers["forward_ports"].each do |port|
        srv.vm.network :forwarded_port, guest: port["guest"], host: port["host"]
      end
      srv.vm.network :private_network, ip: servers["ip"]
      srv.vm.hostname = servers["name"]
#      srv.vm.synced_folder "./dnsmasq", "/home/ubuntu/dnsmasq"
      srv.vm.synced_folder "./docker", "/home/ubuntu/docker"
      srv.vm.synced_folder "./tests", "/home/ubuntu/tests"
      srv.vm.provision :shell, inline: "mkswap -f /swapfile && swapon /swapfile"
      srv.vm.provision :shell, inline: "cp -pR /home/ubuntu/tests /opt/tests"
      srv.vm.provision :shell, inline: "sed -i s/\"127.0.1.1\"/\"#{servers['ip']}\"/ /etc/hosts"
      srv.vm.provision :shell, inline: "rm -f /etc/docker/key.json && systemctl restart docker"
      srv.vm.box = servers["box"]
#      srv.vm.provider :virtualbox do |v|
#        v.cpus = servers["cpu"]
#        v.memory = servers["ram"]
#        v.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
#        v.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
#      end
      config.vm.provision :shell, inline: "apt-get install -y libnss-mdns"
      if srv.vm.hostname.index("master") then
        srv.vm.provision :shell, inline: "cp -f /home/ubuntu/docker/daemon.json.fe /etc/docker/daemon.json && systemctl restart docker"
      else
        srv.vm.provision :shell, inline: "if ! grep :persistent-storage /etc/fstab >/dev/null ;then " +
          "  if [ ! -d /glusterfs ];then mkdir /glusterfs;fi && " +
          "  if [ ! -d /persistent-storage ];then mkdir /persistent-storage;fi && " +
          "  echo \"#{servers['name']}:persistent-storage  /persistent-storage  glusterfs rw,acl,_netdev 0 0\" >/etc/fstab " +
          ";fi"
        srv.vm.provision :shell, inline: "apt-get install -y glusterfs-server"
        srv.vm.provision :shell, inline: "cp -f /home/ubuntu/docker/daemon.json.be /etc/docker/daemon.json && systemctl restart docker"
      end
      servers["shell_commands"].each do |sh|
        srv.vm.provision "shell", inline: sh["shell"]
      end
    end
  end
end
