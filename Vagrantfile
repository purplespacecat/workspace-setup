# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANT_EXPERIMENTAL="disks"

# Test configurations for different distributions
CONFIGS = {
  arch: {
    box: "archlinux/archlinux",
    memory: "2048",
    cpus: "2",
    script: "scripts/install-zsh-arch.sh"
  },
  ubuntu: {
    box: "ubuntu/jammy64",
    memory: "2048",
    cpus: "2",
    script: "scripts/install-zsh-ubuntu.sh"
  }
}

Vagrant.configure("2") do |config|
  CONFIGS.each do |distro, cfg|
    config.vm.define distro.to_s do |d|
      d.vm.box = cfg[:box]
      
      # VM Configuration
      d.vm.provider "virtualbox" do |vb|
        vb.memory = cfg[:memory]
        vb.cpus = cfg[:cpus]
        vb.gui = false
      end

      # Sync the project directory
      d.vm.synced_folder ".", "/vagrant", type: "virtualbox"
      
      # Provision with our setup script
      d.vm.provision "shell", inline: <<-SHELL
        cd /vagrant
        chmod +x #{cfg[:script]}
        ./#{cfg[:script]}
        
        # Test backup functionality
        chmod +x scripts/backup-system.sh
        ./scripts/backup-system.sh
        
        # Verify backup contents
        test -f $HOME/system-backup/$(date +%Y-%m-%d).tar.gz || exit 1
        
        # Test restore functionality
        chmod +x scripts/restore-system.sh
        ./scripts/restore-system.sh $HOME/system-backup/$(date +%Y-%m-%d).tar.gz
        
        # Test shell setup
        test -d $HOME/.oh-my-zsh || exit 1
        test -f $HOME/.zshrc || exit 1
        command -v starship >/dev/null 2>&1 || exit 1
      SHELL
    end
  end
end
