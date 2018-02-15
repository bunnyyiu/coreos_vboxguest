# VirtualBox Guest Addition for CoreOS

## Compile the Guest Addition
Run installVBoxGuest.sh to compile the VirualBox addition

## Install from the prebuilt version (Kerneal 4.14.16 & VirtualBox 5.2.6)
```bash
pushd /opt
sudo tar -xvf vboxguest.gz
```

## Enable the VirtualBox Guest Addition
```bash
sudo modprobe vboxguest
sudo /opt/VBoxGuestAdditions-5.2.6/sbin/VBoxService
```
