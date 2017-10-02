# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  ### GENERAL SETTINGS ###
  # Box to use by default for all machines
  config.vm.box = "debian/jessie64"
  # Additional folders to sync into the boxes
  config.vm.synced_folder "~/.vagrant.d/secrets", "/secrets", 
    type: 'rsync', 
    rsync__auto: true,
    id: 'secrets'

  # Private key path for accessing VMs
  config.ssh.private_key_path = '~/.ssh/vagrant_key' 

  ### DEVELOPMENT BOX DEFINITION ###
  # Settings for the test (dev) machine
  config.vm.define "test", primary: true do |test|
    # Provision with ansible
    test.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "playbook.yml"
      ansible.verbose = true
      ansible.install_mode = "pip"
    end
  end

  ### PRODUCTION FRONT-END BOX DEFINITION ###
  # Settings for the test (dev) machine
  config.vm.define "prod-fe.creativedot.com" do |web|
    # Set the provider specific settings for this box
    web.vm.provider :linode do |provider, override|
      provider.label = 'production-frontend'
    end
    # Provision with ansible
    web.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "playbook_frontend.yml"
      # ansible.verbose = true
      ansible.install_mode = "pip"
    end
  end

  ### PRODUCTION DATABASE BOX DEFINITION ###
  # Settings for the test (dev) machine
  config.vm.define "prod-db.creativedot.com" do |db|
    # Set the provider specific settings for this box
    db.vm.provider :linode do |provider, override|
      provider.label = 'production-database'
    end
    # Provision with ansible
    db.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "playbook_database.yml"
      ansible.verbose = true
      ansible.install_mode = "pip"
    end
  end

  ### PROVIDER SPECIFIC SETTINGS ###
  # Define the VirtualBox specific settings
  config.vm.provider "virtualbox" do |vb, override|
    override.vm.network "private_network", ip: "192.168.4.10"
  end

  # Define the VMWare Fusion sepcific settings
  config.vm.provider "vmware_fusion" do |fusion, override|
    override.vm.network "private_network", ip: "192.168.3.200"
  end

  # Linode provider settings
  config.vm.provider :linode do |provider, override|
    override.ssh.private_key_path = '~/.ssh/vagrant_key'
    override.vm.box = 'linode'
    override.vm.box_url = "https://github.com/displague/vagrant-linode/raw/master/box/linode.box"
    provider.token = File.open(File.expand_path('~/.vagrant.d/linode_api_key'), 'rb') {|f| f.read }
    provider.group = 'production'
    provider.distribution = 'Debian 8'
    provider.datacenter = 'fremont'
    provider.plan = '2048'
    provider.private_networking = true
  end

  config.vm.provider "hyperv" do |provider, override|
    override.ssh.private_key_path = nil
    override.vm.box = "generic/debian8"
    override.vm.synced_folder "./", "/vagrant/", 
      type: 'rsync', 
      rsync__auto: true,
      id: 'ansible'
  end
end