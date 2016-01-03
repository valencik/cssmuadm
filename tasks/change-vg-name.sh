#!/usr/bin/env bash
set -e

#Set hostname
vgrename bubuntu $NEW_VG_NAME
sed -i 's/bubuntu/'"$NEW_VG_NAME"'/g' /etc/fstab
sed -i 's/bubuntu/'"$NEW_VG_NAME"'/g' /boot/grub/grub.cfg

