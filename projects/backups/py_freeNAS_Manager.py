import sys
import argparse
import json
import requests
import yaml
import os
import getpass
import readline # Import this allows the command history to be used during the interaction
import re
import traceback
from enum import Enum

# Type = [Name, GetAllAllowed, CreateAllowed, UpdateAllowed, DeleteAllowed]
class Type(Enum):
    Groups = ['Groups', True, True, True, True]
    Users = ['Users', True, True, True, True]
    ActiveDirectory = ['ActiveDirectory', True, False, True, False]
    LDAP = ['LDAP', True, False, True, False]
    NIS = ['NIS', True, False, True, False]
    NT4 = ['NT4', True, False, True, False]
    Configuration = ['Configuration', True, False, True, False]
    Jails = ['Jails', True, True, False, True]
    MountPoints = ['MountPoints', True, True, True, True]
    Templates = ['Templates', True, True, True, True]
    GlobalConfiguration = ['GlobalConfiguration', True, False, True, False]
    Interface = ['Interface', True, True, True, True]
    VLAN = ['VLAN', True, True, True, True]
    LAGG = ['LAGG', True, True, False, True]
    StaticRoute = ['StaticRoute', True, True, True, True]
    Plugins = ['Plugins', True, False, False, True]
    Services = ['Services', True, False, True, False]
    AFP = ['AFP', True, False, True, False]
    CIFS = ['CIFS', True, False, True, False]
    DomainController = ['DomainController', True, False, True, False]
    DynamicDNS = ['DynamicDNS', True, False, True, False]
    FTP = ['FTP', True, False, True, False]
    LLDP = ['LLDP', True, False, True, False]
    NFS = ['NFS', True, False, True, False]
    Rsyncd = ['Rsyncd', True, False, True, False]
    RsyncMod = ['RsyncMod', True, True, True, True]
    SMART = ['SMART', True, False, True, False]
    SNMP = ['SNMP', True, False, True, False]
    SSH = ['SSH', True, False, True, False]
    TFTP = ['TFTP', True, False, True, False]
    UPS = ['UPS', True, False, True, False]
    Sharing_CIFS = ['Sharing_CIFS', True, True, True, True]
    Sharing_NFS = ['Sharing_NFS', True, True, True, True]
    Sharing_AFP = ['Sharing_AFP', True, True, True, True]
    Volume = ['Volume', True, True, False, True]
    Snapshot = ['Snapshot', True, True, False, True]
    Task = ['Task', True, True, True, True]
    Replication = ['Replication', True, True, True, True]
    Scrub = ['Scrub', True, True, True, True]
    Disk = ['Disk', True, False, True, False]
    Permission = ['Permission', False, False, True, True]
    Advanced = ['Advanced', True, False, True, False]
    Alert = ['Alert', True, False, False, False]
    BootEnv = ['BootEnv', True, True, False, True]
    Email = ['Email', True, False, True, False]
    NTPServer = ['NTPServer', True, True, True, True]
    Reboot = ['Reboot', False, False, False, False]
    Settings = ['Settings', True, False, True, False]
    Shutdown = ['Shutdown', False, False, False, False]
    SSL = ['SSL', False, False, True, False]
    Tunable = ['Tunable', True, True, True, True]
    Version = ['Version', True, False, False, False]
    CronJob = ['CronJob', True, True, True, True]
    InitShutdown = ['InitShutdown', True, True, True, True]
    Rsync = ['Rsync', True, True, True, True]
    SMARTTest = ['SMARTTest', True, True, True, True]

class AddressManager(object):
    def __init__(self, hostname):
        self._base_address = 'http://%s/api/v1.0/' % hostname

        self._addresses = {}

        self._addresses['Groups'] = 'account/groups/'
        self._addresses['Users'] = 'account/users/'
        self._addresses['ActiveDirectory'] = 'directoryservice/activedirectory/'
        self._addresses['LDAP'] = 'directoryservice/ldap/'
        self._addresses['NIS'] = 'directoryservice/nis/'
        self._addresses['NT4'] = 'directoryservice/nt4/'
        self._addresses['Configuration'] = 'jails/configuration/'
        self._addresses['Jails'] = 'jails/jails/'
        self._addresses['MountPoints'] = 'jails/mountpoints/'
        self._addresses['Templates'] = 'jails/templates/'
        self._addresses['GlobalConfiguration'] = 'network/globalconfiguration/'
        self._addresses['Interface'] = 'network/interface/'
        self._addresses['VLAN'] = 'network/vlan/'
        self._addresses['LAGG'] = 'network/lagg/'
        self._addresses['StaticRoute'] = 'network/staticroute/'
        self._addresses['Plugins'] = 'plugins/plugins/'
        self._addresses['Services'] = 'services/services/'
        self._addresses['AFP'] = 'services/afp/'
        self._addresses['CIFS'] = 'services/cifs/'
        self._addresses['DomainController'] = 'services/domaincontroller/'
        self._addresses['DynamicDNS'] = 'services/dynamicdns/'
        self._addresses['FTP'] = 'services/ftp/'
        self._addresses['LLDP'] = 'services/lldp/' 
        self._addresses['NFS'] = 'services/nfs/'
        self._addresses['Rsyncd'] = 'services/rsyncd/'
        self._addresses['RsyncMod'] = 'services/rsyncmod/'
        self._addresses['SMART'] = 'services/smart/'
        self._addresses['SNMP'] = 'services/snmp/'
        self._addresses['SSH'] = 'services/ssh/'
        self._addresses['TFTP'] = 'services/tftp/'
        self._addresses['UPS'] = 'services/ups/'
        self._addresses['Sharing_CIFS'] = 'sharing/cifs/'
        self._addresses['Sharing_NFS'] = 'sharing/nfs/'
        self._addresses['Sharing_AFP'] = 'sharing/afp/'
        self._addresses['Volume'] = 'storage/volume/'
        self._addresses['Snapshot'] = 'storage/snapshot/'
        self._addresses['Task'] = 'storage/task/'
        self._addresses['Replication'] = 'storage/replication'
        self._addresses['Scrub'] = 'storage/scrub/'
        self._addresses['Disk'] = 'storage/disk/'
        self._addresses['Permission'] = 'storage/permission/'
        self._addresses['Advanced'] = 'system/advanced/'
        self._addresses['Alert'] = 'system/alert/'
        self._addresses['BootEnv'] = 'system/bootenv/'
        self._addresses['Email'] = 'system/email/'
        self._addresses['NTPServer'] = 'system/ntpserver/'
        self._addresses['Reboot'] = 'system/reboot/'
        self._addresses['Settings'] = 'system/settings/'
        self._addresses['Shutdown'] = 'system/shutdown/'
        self._addresses['SSL'] = 'system/ssl/'
        self._addresses['Tunable'] = 'system/tunable/'
        self._addresses['Version'] = 'system/version/'
        self._addresses['CronJob'] = 'tasks/cronjob/'
        self._addresses['InitShutdown'] = 'tasks/initshutdown/'
        self._addresses['Rsync'] = 'tasks/rsync/'
        self._addresses['SMARTTest'] = 'tasks/smarttest/'

    def get_address(self, addressType):
        return self._base_address + self._addresses[addressType]

    # def __str__(self):
    #     st = '\n'
    #     for key in self._addresses.keys():
    #         st += ("\t" +key + "\t"+ self.__dict__[key]+"\n")
    #     return st

class FreeNASManager(object):

    def __init__(self, quiet = False, create = True, update = False, delete = False):
        self._manager_config_filename = 'manager_configuration.yaml'
        self._hostname = '0.0.0.0'
        self._running = False

        self._quiet = quiet
        self._permission_create = create
        self._permission_update = update
        self._permission_delete = delete

        # Configuration: user_created_only will not return any built in resources, 
        # leave_ids will not remove ids from the dumped output, dump_for_recreation 
        # will dump the files in the proper format to run them through the manager again
        self._leave_ids = False
        self._dump_all = True
        self._dump_non_builtin = False
        self._include_password = False
        self._auto_create_volumes = True

        self._credentials = {}
        self._able = False

        self.get_manager_configuration()
        self._address_manager = AddressManager(self._hostname)
        self._running = True
    
    def display_config(self):
        print("Hostame:", self._hostname)
        print("Username:", self._credentials['username'], '\n')
        print("Include password:", self._include_password)
        print("Dump all:", self._dump_all)
        print("Dump non built in:", self._dump_non_builtin)
        print("Auto create volumes:", self._auto_create_volumes)
        print("\nCreate permissions:", self._permission_create)
        print("Update permissions:", self._permission_update)
        print("Delete permissions:", self._permission_delete)

    # TODO: Add permissions from configuration file
    def get_manager_configuration(self):
        if os.path.isfile(self._manager_config_filename):
            stream_file = open(os.path.join(os.path.dirname(__file__), self._manager_config_filename), 'r')
            stream = yaml.load(stream_file)

            try:
                self._hostname = stream['hostname']
            except Exception:
                self._hostname = input("Enter your hostname: ")

            # Check for password, if empty -> prompt user
            credentials = {}
            try:
                credentials['username'] = stream['credentials']['username'] # If there is a username, check for a password
                try:
                    credentials['password'] = stream['credentials']['password']
                except Exception:
                    credentials['password'] = getpass.getpass('Enter the password for '+credentials['username']+': ')  
            except KeyError:
                credentials['username'] = input('Enter username: ')
                credentials['password'] = getpass.getpass('Enter the password for '+credentials['username']+': ')   
            self._credentials = credentials

            try:
                self._dump_all = stream['dump_all']
            except Exception:
                self._dump_all = False
            try:
                self._dump_non_builtin = stream['dump_non_builtin']
            except Exception:
                self._dump_non_builtin = False
            try:
                self._auto_create_volumes = stream['auto_create_volumes']
            except:
                self._auto_create_volumes = False

            stream_file.close()
            self._able = True
            return True
        else:
            ans = input("Missing "+self._manager_config_filename+".\nConfigure manually y/[n]: ")
            if ans == 'y':
                ans = input("Dump all [includes built in] y/[n]: ")
                if ans != 'y':
                    self._dump_all = False
                else:
                    self._dump_all = True

                ans = input("Dump all non built in y/[n]: ")
                if ans != 'y':
                    self._dump_non_builtin = False
                else:
                    self._dump_non_builtin = True

                ans = input("Auto create volumes [if non-existing] y/[n]: ")
                if ans != 'y':
                    self._auto_create_volumes = False
                else:
                    self._auto_create_volumes = True

                credentials = {}
                credentials['username'] = input('Enter username: ')
                credentials['password'] = getpass.getpass('Enter the password for '+credentials['username']+': ')   
                self._credentials = credentials
                self._able = True
                return True
            else:
                if not self._running:
                    print("Please add a configuration file and try again.")
                else:
                    print("No configuration file found. No changes were made.")
                self._able = False
                return False

    def delete_all(self, addressType):
        if input("Are you sure you want to delete all "+addressType+"? y/[n]: ") is 'y':
            if not self._quiet:
                print("Deleting all "+addressType+"...")
            current = self.get_all(Type.Rsync, True)
            for i in range(len(current)):
                my_id = current[i]['id']
                self.delete(addressType, my_id)

    def get_all(self, addressType, deleteBuiltin):
        r = json.loads(requests.get(
            self._address_manager.get_address(addressType.value[0]),
            auth=(self._credentials['username'], self._credentials['password']),
            headers={'Content-Type': 'application/json'},
            verify=False,
            data=''
            ).text)

        if (type(r) is dict):
            l = []
            l.append(r)
            r = l

        if deleteBuiltin:
            toRemove = []
            if addressType is Type.Users:
                print(addressType, "has builtins to remove.")
                for user in r:
                    if user['bsdusr_builtin']:
                        toRemove.append(user)
                for user in toRemove:
                    r.remove(user)
            elif addressType is Type.Groups:
                print(addressType, "has builtins to remove.")
                for group in r:
                    if group['bsdgrp_builtin']:
                        toRemove.append(group)
                for group in toRemove:
                    r.remove(group)

        print("\n================================================")
        return r

    # For each Type, get all resources and dump them to .yaml 
    # Result: a folder filled with configuration files
    # TODO: Add a list of types into the configuration [then you can manually determine which files you want to get (rather than just getting them all)]
    def dump_all(self, deleteBuiltin, folderName = '/config_dumped'):
        directory = os.path.dirname(os.path.abspath(__file__))+folderName
        if not os.path.exists(directory):
            os.umask(0o0002)
            os.makedirs(directory)
        for t in Type:
            if t.value[1]: #If the type has get all permissions
                filename = directory+'/config_'+t.name+'.yaml'
                try:
                    self.dump(filename, self.get_all(t, deleteBuiltin), t, True)
                    print (self._address_manager.get_address(t.name))
                except Exception:
                    print("\n================================================")
                    print ("---> Problem with", self._address_manager.get_address(t.name))
                    traceback.print_exc()

        if not self._quiet:
            print("\nFinsished: Configuration files will be located at:\n", directory, "\n")

    def dump(self, config_file_name_output, values, addressType, yes):
        if os.path.isfile(config_file_name_output) and not yes:
            answer = input(config_file_name_output+" already exists, do you want to overwrite y/[n]:")
        else:
            answer = 'y'
        if answer is 'y':
            outputFile = open(config_file_name_output, 'w')
            outputFile.truncate()
            mainList = {}

            # Recreate the proper structure 
            # del creds['password'] #Don't store the password in the output files
            mainList['credentials'] = {}
            mainList['credentials']['username'] = self._credentials['username']
            if self._include_password:
                mainList['credentials']['password'] = self._credentials['password']
            tempList = {}
            valueList = {}
            i = 0
            for value in values:
                valueList[i] = value
                i += 1

            if addressType.value[2]: # value[2] determines whether or not a resource can be created, if not, then add it to to_update
                tempList['to_create'] = valueList
                if not self._quiet:
                    print(addressType.value[0], "- to_create")
            else:
                tempList['to_update'] = valueList
                if not self._quiet:
                    print(addressType.value[0], "- to_update")
            mainList[addressType.value[0]] = tempList   

            stream = yaml.dump(mainList, default_flow_style = False, default_style='')
            outputFile.write(stream.replace('- ', '  '))
            outputFile.close()

    # TODO: If Rsync - check if Volume exists, if not -> create it
    def create(self, params, fileType):
        if not self._quiet:
            print("Creating",fileType,"...")

        # print('%s/' % self._base_address)
        created = requests.post(
            self._address_manager.get_address(fileType),
            auth=(self._credentials['username'], self._credentials['password']),
            headers={'Content-Type': 'application/json'},
            verify=False,
            data=params,
        )

        if not self._quiet:
            print(fileType,"created for user:", self._credentials['username'])
            # print(created.text)

        return created;

    def update(self, params, fileType, my_id):
        if not self._quiet:
            print("Updating",fileType,"...")

        updated = requests.put(
            self._address_manager.get_address(fileType)+'/%s/' % my_id,
            auth=(self._credentials['username'], self._credentials['password']),
            headers={'Content-Type': 'application/json'},
            verify=False,
            data=params,
        )

        if not self._quiet:
            print(fileType,"updated for user:", self._credentials['username'])
            # print(updated.text)

        return updated

    def delete(self, fileType, my_id):
        if not self._quiet:
            print("Deleting",fileType,"...")

        deleted = requests.delete(
            self._address_manager.get_address(fileType)+'/%s/' % my_id,
            auth=(self._credentials['username'], self._credentials['password']),
            headers={'Content-Type': 'application/json'},
            verify=False
        )

        if not self._quiet:
            print(fileType,"deleted for user:", self._credentials['username'])
            # print(deleted.text)

        return deleted

    def process_config_folder(self, folderName = '/config'):
        pathName = os.path.dirname(os.path.realpath(__file__))+folderName
        if not self._quiet:
            print("Parsing files inside", pathName)
        pattern = 'config_.*.ya?ml'

        for f in os.listdir(pathName):
            for match in re.finditer(pattern, f):
                s = match.start()
                e = match.end()
                fileType = Type.Rsync
                for t in Type:
                    for m in re.finditer(t.name, f):
                        s2 = m.start()
                        e2 = m.end()
                        fileType = t
                        break
                self.process_config_file(pathName+'/'+f[s:e], fileType.name, f[s:e])

    def process_config_file(self, config_filename, fileType, shortName):
        if not self._quiet:
            print("Starting to process ../" + shortName)
        
        stream_file = open(os.path.join(os.path.dirname(__file__), config_filename), 'r')
        stream = yaml.load(stream_file)
        stream_file.close()

        credentials = self._credentials

        to_create = {}
        to_update = {}
        to_delete = {}
        # Process the list of tokens to create
        if self._permission_create:
            try:
                to_create = stream[fileType]['to_create']
                for i in range(len(to_create)):
                    if fileType is Type.Rsync:
                        to_create[i]['rsync_user'] = self._credentials['username']
                    self.create(json.dumps(to_create[i]), fileType)
            except Exception:
                if not self._quiet:
                    print("Nothing to create ... ")

        # Process the list of tokens to update
        if self._permission_update:
            try:
                to_update = stream[fileType]['to_update']
                for i in range(len(to_update)):
                    my_id = to_update[i]['id']
                    if fileType is Type.Rsync:
                        to_update[i]['rsync_user'] = self._credentials['username']
                    self.update(json.dumps(to_update[i]), fileType, my_id)
            except Exception:
                if not self._quiet:
                    print("Nothing to update ... ") 


        # Process the list of tokens to delete
        if self._permission_delete:
            try:
                to_delete = stream[fileType]['to_delete']
                for i in range(len(to_delete)):
                    my_id = to_delete[i]['id']
                    self.delete(fileType, my_id)
            except Exception:
                if not self._quiet:
                    print("Nothing to delete ... ")

        if not self._quiet:
            print("Finished processing ../" + shortName)

prompt = '>> '
class Commands(Enum):
    exit = [0, "     Stop the manager"]
    help = [1, "     List all commands"]
    dump = [2, "     Get all [non built in] resources to config folder"]
    dumpb = [3, "    Get all [built in included] resources to config folder"]
    process = [4, "  Process a folder of yaml files" ]
    config = [5, "   Process a configuration file"]
    display = [6, "  Display the current configuration"]
    deleteall = [7, "Delete all of type ..."]

    # TODO: Add in an option to list types and properties

def exit(manager, args):
    print("Bye")
    return False

def help(manager, args):
    for command in Commands:
        print(command.value[0], command.name+ ":", command.value[1])
    return True

def dump(manager, args):
    print("Dump all non built in resources to config files")
    if len(args) > 0:
        manager.dump_all(True, args[0])
    else:
        outputFolder = input("Folder name [/config_dumped]:")
        if len(outputFolder) > 0:
            manager.dump_all(True, outputFolder)
        else:
            manager.dump_all(True)
    return True

def dumpb(manager, args):
    print("Dumping all [built in included] resources")
    if len(args) > 0:       manager.dump_all(False, args[0])
    else:
        outputFolder = input("Folder name [/config_dumped]:")
        if len(outputFolder) > 0:
            manager.dump_all(False, outputFolder)
        else:
            manager.dump_all(False)
    return True

def process(manager, args):
    print("")
    if len(args) > 0:
        manager.process_config_folder(args[0])
    else:
        # TODO: Prompt for a config folder name [if nothing, use /config]
        manager.process_config_folder()
    print("")
    return True

def config(manager, args):
    if manager.get_manager_configuration():
        print("\nManager has been (re)configured.\n")
    return True

def display(manager, args):
    manager.display_config()
    return True

def deleteall(manager, args):
    # if args[0] is a real type
    my_type = 'Rsync'
    if len(args) == 0:
        my_type = input("What type of resource do you want to delete: ")
    else:
        my_type = args[0]

    for t in Type:
        if my_type == t.name:
            manager.delete_all(my_type)
            return True
    print("\nInvalid type.\n")
    return True

def parse_input(inputCommand, manager):
    for command in Commands:
        args = inputCommand.split()
        if args[0] == command.name or str(args[0]) == str(command.value[0]):
            return globals()[command.name](manager, args[1:])
    print(prompt,inputCommand, "is not a command that I know. Try again. [use help for more commands]")
    return True

def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument('-H', '--hostname', required=False, type=str)
    parser.add_argument('-co', '--config', required=False, type=str)

    args = parser.parse_args(sys.argv[1:])

    # manager =  FreeNASManager(args.hostname, args.config)
    manager =  FreeNASManager()
    
    yes = manager._able
    if yes:
        print("Welcome to the FreeNAS API Manager.\nFor more documentation....[will be updated]\n\n  >> help [display commands]\n  >> 1    [display commands]\n")
    while(yes):
        yes = parse_input(input(prompt), manager)


if __name__ == '__main__':
    main(sys.argv[1:])
