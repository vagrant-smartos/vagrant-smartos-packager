# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 3072
  end

  config.vm.box = "SmartOS-20140307T223339Z"
  config.vm.box_url = "https://us-east.manta.joyent.com/wanelo/public/cache/vagrant/boxes/SmartOS-20140221T042147Z.box"

  #config.vm.network "private_network", ip: "192.168.50.4"
  #config.vm.synced_folder ".", "/vagrant", type: "nfs"
  config.vm.synced_folder ".", "/vagrant", type: "rsync"

  config.vm.provision "shell",
    inline: %{
      if [[ ! -e /var/db/imgadm/sources.list || `grep -v "https://datasets.joyent.com/datasets" /var/db/imgadm/sources.list` ]]; then
        echo "https://datasets.joyent.com/datasets" >> /var/db/imgadm/sources.list
      fi

      imgadm update

      imgadm import 75ec04ce-55fe-11e3-9252-afb57e4da368
      imgadm import c353c568-69ad-11e3-a248-db288786ea63

      export GATEWAY=$(netstat -r | grep default | awk '{ print $2 }')

      if [[ ! `vmadm list -H alias=manage` ]]; then
        echo "{
          \"brand\": \"joyent\",
          \"dataset_uuid\": \"c353c568-69ad-11e3-a248-db288786ea63\",
          \"quota\": 1,
          \"max_physical_memory\": 64,
          \"alias\": \"manage\",
          \"nics\": [
            {
              \"nic_tag\": \"admin\",
              \"ip\": \"dhcp\"
            }
          ]
        }" | vmadm create
      fi
  }

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network :public_network

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  # config.vm.provision :chef_solo do |chef|
  #   chef.cookbooks_path = "../my-recipes/cookbooks"
  #   chef.roles_path = "../my-recipes/roles"
  #   chef.data_bags_path = "../my-recipes/data_bags"
  #   chef.add_recipe "mysql"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
  #   chef.json = { :mysql_password => "foo" }
  # end
end
