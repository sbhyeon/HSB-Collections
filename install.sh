#!/bin/bash

if [ $EUID -ne 0 ]; then
        echo ERROR: You must run this as root
        exit
fi

RUID=$(who | awk 'FNR == 1 {print $1}')

echo "Copy gtk theme files ..."
echo "background files.."
mkdir -p /usr/share/backgrounds
cp -r ./backgrounds/HSB-Collections /usr/share/backgrounds/

echo "font files.."
mkdir -p /usr/share/fonts/truetype
cp -r ./fonts/HSB-Collections /usr/share/fonts/truetype/

echo "grub theme files.."
mkdir -p /boot/grub/themes
cp -r ./grub_themes/HSB-Collections /boot/grub/themes/

echo "icon files.."
cp -r ./icons/HSB-Collections /usr/share/icons/

echo "plymouth theme files.."
mkdir -p /usr/share/plymouth/themes
cp -r ./plymouth_themes/HSB-Collections /usr/share/plymouth/themes/

echo "gtk-theme files.."
mkdir -p /usr/share/themes
cp -r ./themes/HSB-Collections /usr/share/themes/

echo "Install grub theme ..."
THEME='HSB-Collections'
echo "GRUB_THEME=/boot/grub/themes/${THEME}/theme.txt" | sudo tee -a /etc/default/grub
update-grub

echo "Install plymouth theme ..."
THEME='HSB-Collections'
INSTALLDIR=/usr/share/plymouth/themes
apt update
apt install -y plymouth-themes

printf "Installing '${THEME}' theme..."
update-alternatives --quiet --install ${INSTALLDIR}/default.plymouth default.plymouth ${INSTALLDIR}/${THEME}/${THEME}.plymouth 100
printf "... DONE\n"

printf "Selecting '${THEME}' theme..."
update-alternatives --quiet --set default.plymouth ${INSTALLDIR}/${THEME}/${THEME}.plymouth
printf ".... DONE\n"

printf "Updating initramfs...\n"
update-initramfs -u

#echo "Install extra packages for DevEnv ..."
#apt install -y build-essential git curl

#echo "Install Plank ..."
#apt install -y plank

#echo "Install extra packages for Virtualization ..."
#apt install -y qemu qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager libguestfs-tools

#echo "KVM kernel module load ..."
#systemctl enable --now libvirtd
#systemctl enable --now virtlogd
#echo 1 | sudo tee /sys/module/kvm/parameters/ignore_msrs
#modprobe kvm
#usermod -aG libvirt ${RUID}
#usermod -aG kvm ${RUID}

#echo "Install Docker engine ..."
#apt update
#apt install -y apt-transport-https ca-certificates software-properties-common
#apt remove -y docker docker-engine docker.io containerd runc
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
#echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu jammy stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
#apt update
#apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
#usermod -aG docker ${RUID}

printf "DONE\n"
