General Notes
=============

Grab the latest FreeNAS iso from [http://www.freenas.org](http://www.freenas.org/download-freenas-release.html)

Copy the freeNAS installer to a USB flash drive.

Instructions for Mac OS X:

```bash
hdiutil convert FreeNAS-9.3-STABLE-201505130355.iso  -format UDRW -o freenas.img
diskutil unmountDisk /dev/diskX
dd if=freenas.img of=/dev/diskX bs=1m
```


Issues
======

- Can only use USB2 ports for booting

