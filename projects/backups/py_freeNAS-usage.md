# Rsync Manager
### Usage  
##### Default Manager with creation permissions:
```sh
$ python3 py_freeNAS.py -H 192.168.3.136 -co config_rsync_tasks.yml -c t 
$ python3 py_freeNAS.py -H 192.168.3.136 -co config_users.yml -c t
$ python3 py_freeNAS.py -H 192.168.3.136 -co config_groups.yml -c t
```
##### Manager with all permissions:
```sh
$ python3 py_freeNAS.py -H 192.168.3.136 -co config_rsync_tasks.yml -c t -up t -d t
```
##### Manager with all permissions, no logging:
```sh
$ python3 rsync_manager.py -H 192.168.0.46 -co config_users.yml -c t -d t -up t -q t
```
##### Delete all rsync tasks:
```sh
$ python3 py_freeNAS.py -H 192.168.3.136 -co config_rsync_tasks.yml -dat t
```
##### Delete all [user created] users:
```sh
$ python3 py_freeNAS.py -H 192.168.3.136 -co config_rsync_tasks.yml -dau t
```
##### Delete all [user created] groups:
```sh
$ python3 py_freeNAS.py -H 192.168.3.136 -co config_rsync_tasks.yml -dag t
```
```sh
-H     : hostname  
-co    : configuration file (yaml)  
-c  t  :  turn on creation permissions  
-d  t  : turn on deletion permissions  
-up t  : turn on updating permissions   
-q  t  : turn logging off 
```
### Sample config_rsync_tasks.yml
```sh
# --- !Sample yaml file for testing
credentials:
  username:  'root'
  password:  'admin'
rsync_tasks:
    to_create:
      0:
        rsync_mode: 'module'
        rsync_path: '/mnt/Disk'
        rsync_remotehost: 'cs.smu.ca'
        rsync_remoteport:  22
        rsync_remotemodule: 'TestTask1'
        rsync_remotepath:  ''
        rsync_direction: 'push'
        rsync_minute: '*'
        rsync_hour: '*'
        rsync_daymonth: '*'
        rsync_month:  '*'
        rsync_dayweek:  '*'
        rsync_desc:  ''
        rsync_delayupdates:  true
        rsync_enabled:  true
        rsync_archive:  false
        rsync_compress:  true
        rsync_extra:  ''
        rsync_quiet:  false
        rsync_recursive:  true
        rsync_times:  true
      1:
        rsync_mode: 'module'
        rsync_path: '/mnt/Disk'
        rsync_remotehost: 'cs.smu.ca'
        rsync_remoteport:  22
        rsync_remotemodule: 'TestTask2'
        rsync_remotepath:  ''
        rsync_direction: 'push'
        rsync_minute: '*'
        rsync_hour: '*'
        rsync_daymonth: '*'
        rsync_month:  '*'
        rsync_dayweek:  '*'
        rsync_desc:  ''
        rsync_delayupdates:  true
        rsync_enabled:  true
        rsync_archive:  false
        rsync_compress:  true
        rsync_extra:  ''
        rsync_quiet:  false
        rsync_recursive:  true
        rsync_times:  true  
      2:
        rsync_mode: 'module'
        rsync_path: '/mnt/Disk'
        rsync_remotehost: 'cs.smu.ca'
        rsync_remoteport:  22
        rsync_remotemodule: 'TestTask3'
        rsync_remotepath:  ''
        rsync_direction: 'push'
        rsync_minute: '*'
        rsync_hour: '*'
        rsync_daymonth: '*'
        rsync_month:  '*'
        rsync_dayweek:  '*'
        rsync_desc:  ''
        rsync_delayupdates:  true
        rsync_enabled:  true
        rsync_archive:  false
        rsync_compress:  true
        rsync_extra:  ''
        rsync_quiet:  false
        rsync_recursive:  true
        rsync_times:  true
    to_update:
      0:
        id:  1
        rsync_mode: 'module'
        rsync_path: '/mnt/Disk'
        rsync_remotehost: 'cs.smu.ca'
        rsync_remoteport:  22
        rsync_remotemodule: 'UpdatedTaskName'
        rsync_remotepath:  ''
        rsync_direction: 'push'
        rsync_minute: '*'
        rsync_hour: '*'
        rsync_daymonth: '*'
        rsync_month:  '*'
        rsync_dayweek:  '*'
        rsync_desc:  ''
        rsync_delayupdates:  false
        rsync_enabled:  true
        rsync_archive:  true
        rsync_compress:  false
        rsync_extra:  ''
        rsync_quiet:  false
        rsync_recursive:  false
        rsync_times:  true
    to_delete:
      0:
        id:  2
      1:
        id:  3

```
### Sample config_users.yml
```sh
# --- !Sample yaml file for testing
credentials:
  username:  'root'
  password:  'admin'
users:
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
      1:
        bsdusr_username: "testUser2"
        bsdusr_password: "password"
        bsdusr_full_name: "User2"
        bsdusr_creategroup: true
        bsdusr_uid: 1112
        bsdusr_group: 1
        bsdusr_mode: ""
        bsdusr_shell: "/bin/sh"
        bsdusr_password_disabled: false
        bsdusr_locked: false
        bsdusr_sudo: false
        bsdusr_sshpubkey: ""
    to_update:
      0:
        id:  28
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
    to_delete:
      0:
        id:  28
```
### Sample config_groups.yml
```sh
# --- !Sample yaml file for testing
credentials:
  username:  'root'
  password:  'admin'
groups:
    to_create:
      0:
        id: 2001
        bsdgrp_gid:  2001
        bsdgrp_group: "TestGroup1"
        bsdgrp_sudo: false
      1:
        id: 2002
        bsdgrp_gid:  2002
        bsdgrp_group: "TestGroup2"
        bsdgrp_sudo: false
    to_update:
    # id = current id, bsdgrp_gid = new id
      0:
        id:  2001
        bsdgrp_gid:  3001
        bsdgrp_group: "NewGroupName1"
        bsdgrp_sudo: true
      1:
        id: 2002
        bsdgrp_gid:  3002
        bsdgrp_group: "NewGroupName2"
        bsdgrp_sudo: false
    to_delete:
      0:
        id:  2001
```