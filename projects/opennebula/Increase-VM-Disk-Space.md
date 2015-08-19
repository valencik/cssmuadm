# Increase a VM's disk space

In order to increase a virtual machine's disk space we'll create a new datablock image,
use it to extend the logical volume, and then grow the filesystem.


## Host: Create the drive

First we need to create a new datablock image
```
oneadmin@hf:~$ oneimage create --datastore default --name csci2356data --type DATABLOCK \ 
--persistent --fstype ext4 --size 30720 --description "CSCI2356 /home and /data"
```

Now mount the image to the virtual machine
```
oneadmin@hf:~$ onevm disk-attack VMname --image csci2356data
```

---


## VM: Find the drive

Rescan the scsi hosts for the new disk if it doesn't show up
```
root@ubuntu:~# ls /sys/class/scsi_host/
root@ubuntu:~# echo "- - -" > /sys/class/scsi_host/host2/scan
#Watch for kernel messages
root@ubuntu:~# tail -f /var/log/kern.log
#Make sure the new disk is recognized
root@ubuntu:~# fdisk -l
```

## Create LVM partition

`fdisk /dev/sdX`  
Create a new partition `n` and accept the defaults (primary, first partition, earliest sector, and last sector)  
Change the partition type `t` to '8e' which is 'Linux LVM'  
Confirm your changes by printing the partition table with `p`  
If correct, write your changes to disk with `w`  

Confirm the partition exists with `fdisk -l /dev/sdX`  


## Extend the Volume Group

Our goal is to extend the size of a particular lvm logical volume (root).  
In order to do so we need to have the space available on a lvm physical volume that is part of the
same lvm volume group as the target logical volume.
Use `lvdisplay`, `vgdisplay`, and `pvdisplay` to confirm the details of your system.  

Create a lvm physical volume with our newly formatted partition:  
```
pvcreate /dev/sdX1
```

Extend the existing lvm volume group that your logical volume is on with the new physical volume `/dev/sdX1`:  
```
vgextend ubuntu-vg /dev/sdX1
```

## Option 1: Extend the Logical Volume
Extend the desired lvm logical volume
```
lvextend /dev/ubuntu-vg/root /dev/sdb1
```

## Option 2: Remove Old Physical Volumes

If we want to simplify the number of images connected to the VM we can replace old physical volumes with one new larger one.
In order to do this we must relocate physical extents.

```
pvmove /dev/sda1
```

Once a physical volume has zero allocated physical extents we can remove it from the volume group.

```
vgreduce ubuntu-vg /dev/sda1
```

And once removed from the volume group we can remove it as a physical volume.

```
pvremove /dev/sda1
```

At this stage the image is no longer a part of the guest LVM system and can be unmounted.

## Resize the filesystem

Now we need to grow the filesystem to match the resized logical volume:  
(Your OS needs to support online resizing, which the linux kernel 2.6+ does)
```
resize2fs /dev/ubuntu-vg/root
```

