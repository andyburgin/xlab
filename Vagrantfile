# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

    # Tells us if the host system is an Apple Silicon Mac running Rosetta
    def running_rosetta()
      !`sysctl -in sysctl.proc_translated`.strip().to_i.zero?
    end
  
    arch = `arch`.strip()
    if arch == 'arm64' || (arch == 'i386' && running_rosetta()) # is M1
      config.vm.box = "multipass"
    else # not M1
      config.vm.box = "ubuntu/bionic64"
    end

    config.vm.provider "multipass" do |multipass, override|
        multipass.hd_size = "10G"
        multipass.cpu_count = 2
        multipass.memory_mb = 3072
        multipass.image_name = "bionic"
      end    

      config.vm.provision :docker
      config.vm.define "xlab-interview"
      config.vm.hostname = "xlab-interview"
      config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ".git/"
  
      config.vm.provision :shell,
      keep_color: true,
      privileged: false,
      run: "always",
      path: "./run.sh"
end