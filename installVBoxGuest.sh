#!/bin/bash

# setup writable overlay on /lib/modules
modules=/opt/modules  # Adjust this writable storage location as needed.
sudo mkdir -p "$modules" "$modules.wd"
sudo mount \
    -o "lowerdir=/lib/modules,upperdir=$modules,workdir=$modules.wd" \
    -t overlay overlay /lib/modules

# prepare coreos development container
. /usr/share/coreos/release
. /usr/share/coreos/update.conf
url="http://${GROUP:-stable}.release.core-os.net/$COREOS_RELEASE_BOARD/$COREOS_RELEASE_VERSION/coreos_developer_container.bin.bz2"

gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 04127D0BFABEC8871FFB2CCE50E0885593D2DCB4  # Fetch the buildbot key if neccesary.
curl -L "$url" |
    tee >(bzip2 -d > coreos_developer_container.bin) |
    gpg2 --verify <(curl -Ls "$url.sig") -

# download the vboxguest.iso and mount it
export VBOX_VERSION=5.2.6
curl -L -o vboxguest.iso http://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso
mkdir -p /media/guest
sudo mount -o loop vboxguest.iso /media/guest/

# download the linux kernel source code, compile vbox related modules
sudo systemd-nspawn \
    --bind=/lib/modules \
    --bind=/media/guest \
    --bind=/opt \
    --image=coreos_developer_container.bin \
    --image=coreos_developer_container.bin \
    /bin/bash << EOF
emerge-gitclone
emerge -gKv coreos-sources
gzip -cd /proc/config.gz > /usr/src/linux/.config
make -C /usr/src/linux modules_prepare
pushd /media/guest
./VBoxLinuxAdditions.run
EOF

# to run the vboxguest
#sudo modprobe vboxguest
#pushd /opt/VBoxGuestAdditions-5.2.6/sbin
#sudo ./VBoxService

pushd /opt
sudo tar -zcvf vboxguest.gz modules VBoxGuestAdditions-5.2.6
