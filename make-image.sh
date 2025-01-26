#!/bin/bash

# This script is used to download the cloud image and create a new VM with it.
# Is uses cloud-init to configure the VM.

img_file="noble-server-cloudimg-amd64.img"
iso_file="cloud-init.iso"

if [ -f $img_file ]; then
  read -p "Image file already exists. Do you want to overwrite it? [y/N] " yn
  case $yn in
    [Yy]* ) rm $img_file;;
    no|n|* ) echo "Exiting..."; exit;;
  esac
fi

wget https://cloud-images.ubuntu.com/noble/current/$img_file
qemu-img resize $img_file +4G

if [ -f $iso_file ]; then
  rm $iso_file
fi

genisoimage -output $iso_file -volid cidata -joliet -rock user-data meta-data

# Prompt the user before starting the VM
echo "\nFirst boot will take some time to configure the VM. It uses cloud-init to configure the VM."
read -p "Press enter to start the VM..."

qemu-system-x86_64 \
  -smp 2 -m 2G -nographic \
  -enable-kvm \
  -hda ./$img_file \
  -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp::2200-:22 \
  -cdrom ./$iso_file
