# FreeNAS API Manager
### Usage  
##### Requirements:
```
manager_configuration.yaml placed in root directory [example below]
```
##### To Run [from root directory]:
```sh
$ python3 py_freeNAS_Manager.py 

Welcome to the FreeNAS API Manager.
For more documentation.... [will be updated]

  >> help [display commands]
  >> 1    [display commands]

>>
```
##### Commands:
```sh
0 exit:      Stop the manager
1 help:      List all commands
2 dump:      Get all [non built in] resources to config folder
3 dumpb:     Get all [built in included] resources to config folder
4 process:   Process a folder of yaml files
5 config:    Process a configuration file
6 display:   Display the current configuration
7 deleteall: Delete all of type ...
```

##### Examples:
##### Dump resources [Built in resources not included]
```sh
>> dump
Dump all non built in resources to config files
Folder name [/config_dumped]:

Type.Groups has builtins to remove.
================================================
Groups - to_create
http://0.0.0.0/api/v1.0/account/groups/

[...]

================================================
SMARTTest - to_create
http://0.0.0.0/api/v1.0/tasks/smarttest/

Finsished: Configuration files will be located at:
 /rootDirectory/config_dumped 
```
##### Dump resources [Built in resources included]
```sh
>> dumpb
Dumping all [built in included] resources
Folder name [/config_dumped]:

================================================
Groups - to_create
http://0.0.0.0/api/v1.0/account/groups/

[...]

================================================
SMARTTest - to_create
http://0.0.0.0/api/v1.0/tasks/smarttest/

Finsished: Configuration files will be located at:
 /rootDirectory/config_dumped
```
##### Process config files in a folder [/config (see below)]
```sh
>> process

Parsing files inside /rootDirectory/config
Starting to process ../config_Groups.yaml
Creating Groups ...
Groups created for user: root
Finished processing ../config_Groups.yaml
Starting to process ../config_Users.yaml
Creating Users ...
Users created for user: root
Finished processing ../config_Users.yaml
Starting to process ../config_Rsync.yml
Creating Rsync ...
Rsync created for user: root
Finished processing ../config_Rsync.yml
```
##### Reconfigure the manager [using manager_configuration.yaml]:
```sh
>> config

Manager has been (re)configured.
```
##### Reconfigure the manager [without manager_configuration.yaml]:
```sh
>> config
Missing manager_configuration.yaml.
Configure manually y/[n]: y
Dump all [includes built in] y/[n]: y
Dump all non built in y/[n]: 
Auto create volumes [if non-existing] y/[n]: y
Enter username: root
Enter the password for root: 

Manager has been (re)configured
```
##### Missing configuration file:
```sh
Missing manager_configuration.yaml.
Configure manually y/[n]: n
Please add a configuration file and try again.
```
##### Display current configuration:
```sh
>> display
Hostame: 0.0.0.0
Username: root 

Include password: False
Dump all: True
Dump non built in: True
Auto create volumes: True

Create permissions: True
Update permissions: False
Delete permissions: False
```
```
Get: /api/v1.0/
Return a list of all resources
- Account 
  - Groups               : account/groups/
  - Users                : account/users/
- Directory Service
  - ActiveDirectory      : directoryservice/activedirectory/
  - LDAP                 : directoryservice/ldap/
  - NIS                  : directoryservice/nis/
  - NT4                  : directoryservice/nt4/
  - Idmap           ***
- Jails
  - Configuration        : jails/configuration/
  - Jails                : jails/jails/
  - MountPoints          : jails/mountpoints/
  - Templates            : jails/templates/
- Network
  - Global Configuration : network/globalconfiguration/
  - Interface            : network/interface/
  - VLAN                 : network/vlan/
  - LAGG                 : network/lagg/
  - Static Route         : network/staticroute/
- Plugins
  - Plugins              : plugins/plugins/
- Services
  - Services             : services/services/
  - AFP                  : services/afp/
  - CIFS                 : services/cifs/
  - Domain Controller    : services/domaincontroller/
  - DynamicDNS           : services/dynamicdns/
  - FTP                  : services/ftp/
  - iSCSI                ***
  - LLDP                 : services/lldp/      
  - NFS                  : services/nfs/
  - Rsyncd               : services/rsyncd/
  - RsyncMod             : services/rsyncmod/
  - SMART                : services/smart/
  - SNMP                 : services/snmp/
  - SSH                  : services/ssh/
  - TFTP                 : services/tftp/
  - UPS                  : services/ups/
- Sharing
  - CIFS                 : sharing/cifs/
  - NFS                  : sharing/nfs/
  - AFP                  : sharing/afp/
- Storage
  - Volume               : storage/volume/
  - Snapshot             : storage/snapshot/
  - Task                 : storage/task/
  - Replication          : storage/replication/
  - Scrub                : storage/scrub/
  - Disk                 : storage/disk/
  - Permission           : storage/permission/
- System
  - Advanced             : system/advanced/
  - Alert                : system/alert/
  - BootEnv              : system/bootenv/
  - Email                : system/email/
  - NTPServer            : system/ntpserver/
  - Reboot               : system/reboot/
  - Settings             : system/settings/
  - Shutdown             : system/shutdown/
  - SSL                  : system/ssl/
  - Tunable              : system/tunable/
  - Version              : system/version/
- Tasks
  - CronJob              : tasks/cronjob/
  - InitShutdown         : tasks/initshutdown/
  - Rsync                : tasks/rsync/
  - SMARTTest            : tasks/smarttest/
  ```
### Sample manager_configuration.yaml
```
hostname: 0.0.0.0
credentials:
    username:  'root'
    password:  'secret'
include_password:  false
dump_all:  true
dump_non_builtin:   true
auto_create_volumes:  true 
permission_create:  true
permission_update:  true
permission_delete:  true
```
### /config
##### ../config_Groups.yaml
```sh
Groups:
  to_create:
    0:
      id: 2001
      bsdgrp_gid:  2001
      bsdgrp_group: "TestGroup1"
      bsdgrp_sudo: false
```
##### ../config_Users.yaml
```sh
Users:
    to_create:
      0:
        bsdusr_username: "testUser1"
        bsdusr_password: "password"
        bsdusr_full_name: "User"
        bsdusr_creategroup: true
        bsdusr_uid: 1111
        bsdusr_group: 1
        bsdusr_mode: ""
        bsdusr_shell: "/bin/sh"
        bsdusr_password_disabled: false
        bsdusr_locked: false
        bsdusr_sudo: false
        bsdusr_sshpubkey: ""
    to_update:
    to_delete:
```
##### ../config_Rsync.yaml
```sh
Rsync:
  to_create:
    0:
      rsync_archive: true
      rsync_compress: false
      rsync_daymonth: '*'
      rsync_dayweek: '*'
      rsync_delayupdates: false
      rsync_delete: false
      rsync_desc: ''
      rsync_direction: push
      rsync_enabled: true
      rsync_extra: ''
      rsync_hour: '*'
      rsync_minute: '*'
      rsync_mode: module
      rsync_month: '*'
      rsync_path: /mnt/Disk
      rsync_preserveattr: false
      rsync_preserveperm: false
      rsync_quiet: false
      rsync_recursive: false
      rsync_remotehost: cs.smu.ca
      rsync_remotemodule: RsyncTaskName
      rsync_remotepath: ''
      rsync_remoteport: 22
      rsync_times: true
      rsync_user: root
  to_update:
  to_delete:
```
