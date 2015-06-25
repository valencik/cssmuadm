# Rsync Manager
### Usage  
##### Default Manager with creation permissions:
```sh
$ python3 rsync_manager.py -H 192.168.0.46 -co config.yml 
```
##### Manager with all permissions:
```sh
$ python3 rsync_manager.py -H 192.168.0.46 -co config.yml -c t -d t -u t
```
##### Manager with creating, deletion and updating permissions, no logging:
```sh
$ python3 rsync_manager.py -H 192.168.0.46 -co config.yml -c t -d t -u t -q t
```
-H : hostname  
-co : configuration file (yaml)  
##### The following are all optional:  
-c t :  turn on creation permissions  [On by default]  
-d t : turn on deletion permissions   [Off by default]  
-u t : turn on updating permissions   [Off by default]  
-q t : turn logging off [Logging on by default]

### Sample config.yml
This file is configured to create one task called YamlTest on Disk1.   
All options are available for configuration. Currently the updating and deleteing are not implemented.
```sh
# --- !Sample yaml file for testing
credentials:
  username:  'root'
  password:  'admin'
rsync_tasks_to_create:
  task0:
    rsync_mode: 'module'
    rsync_path: '/mnt/Disk1'
    rsync_remotehost: 'cs.smu.ca'
    rsync_remoteport:  22
    rsync_remotemodule: 'YamlTest'
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
rsync_tasks_to_update:
  task0:
    id:  1
rsync_tasks_to_delete:
  task0:
    id:  1
```

```sh
# --- !Sample yaml file for testing
credentials:
  username:  'root'
  password:  'admin'
rsync_tasks_to_create:
  task0:
    rsync_mode: 'module'
    rsync_path: '/mnt/Disk1'
    rsync_remotehost: 'cs.smu.ca'
    rsync_remoteport:  22
    rsync_remotemodule: 'YamlTest'
    rsync_remotepath:  ''
    rsync_direction: 'push'
    rsync_minute: '*/20'
    rsync_hour: '*/2'
    rsync_daymonth: '*'
    rsync_month:  '2'
    rsync_dayweek:  '*/3'
    rsync_desc:  ''
    rsync_delayupdates:  true
    rsync_enabled:  true
    rsync_archive:  false
    rsync_compress:  true
    rsync_extra:  ''
    rsync_quiet:  false
    rsync_recursive:  true
    rsync_times:  true
```
