# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 3072
  end

  # See https://vagrantcloud.com/livinginthepast for SmartOS boxes
  config.vm.box = "livinginthepast/smartos-base64-13.4.0"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  #config.vm.network "private_network", ip: "192.168.50.4"
  #config.vm.synced_folder ".", "/vagrant", type: "nfs"
  #config.vm.synced_folder ".", "/zones/vagrant", type: "rsync"

  # Requires vagrant plugin at https://github.com/sax/vagrant-smartos-zones
  #config.global_zone.platform_image = '20140321T062644Z'

  config.zone.name = 'base64'
  config.zone.brand = 'joyent'
  config.zone.image = 'c353c568-69ad-11e3-a248-db288786ea63'
  config.zone.memory = 2048
  config.zone.disk_size = 5
end
