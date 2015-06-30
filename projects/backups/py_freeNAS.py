import sys
import argparse
import json
import requests
import yaml
import os
import getpass
from enum import Enum

class Type(Enum):
    no_type = 0
    rsync_tasks = 1
    users = 2
    groups = 3
    task = 4

class FreeNASManager(object):

    def __init__(self, hostname, config_file_name, quiet = False, create = True, update = False, delete = False):
        self._hostname = hostname
        self._quiet = quiet
        self._config_file_name = config_file_name
        self._permission_create = create
        self._permission_update = update
        self._permission_delete = delete

        self._type = Type.no_type

        self._rsync_address = '/tasks/rsync'
        self._user_address = '/account/users'
        self._group_address = '/account/groups'
        self._base_address = 'http://%s/api/v1.0' % hostname

    def display_configuration(self):
        print("Creation permissions", "on" if self._permission_create else "off")
        print("Updating permissions", "on" if self._permission_update else "off")
        print("Deletion permissions", "on" if self._permission_delete else "off")

    def create(self, params, credentials):
        if not self._quiet:
            print("Creating",self._type.name,"...")

        created = requests.post(
            '%s/' % self._base_address,
            auth=(credentials['username'], credentials['password']),
            headers={'Content-Type': 'application/json'},
            verify=False,
            data=params,
        )

        if not self._quiet:
            print(self._type.name,"created for user:", credentials['username'])
            print(created.text)

        return created;

    def update(self, params, credentials, my_id):
        if not self._quiet:
            print("Updating",self._type.name,"...")

        updated = requests.put(
            '%s/%s/' % (self._base_address, my_id),
            auth=(credentials['username'], credentials['password']),
            headers={'Content-Type': 'application/json'},
            verify=False,
            data=params,
        )

        if not self._quiet:
            print(self._type.name,"updated for user:", credentials['username'])
            print(updated.text)

        return updated

    def delete(self, credentials, my_id):
        if not self._quiet:
            print("Deleting",self._type.name,"...")

        print('%s/%s/' % (self._base_address, my_id))
        deleted = requests.delete(
            '%s/%s/' % (self._base_address, my_id),
            auth=(credentials['username'], credentials['password']),
            headers={'Content-Type': 'application/json'},
            verify=False
        )

        if not self._quiet:
            print(self._type.name,"deleted for user:", credentials['username'])
            print(deleted.text)

        return deleted

    def process_config_file(self):
        if not self._quiet:
            print("Starting to process", self._config_file_name)
        
        stream_file = open(os.path.join(os.path.dirname(__file__), self._config_file_name), 'r')
        stream = yaml.load(stream_file)
        stream_file.close()

        # Check for password, if empty -> prompt user
        try:
            password = stream['credentials']['password']
        except Exception:
            stream['credentials']['password'] = getpass.getpass('Enter the password for '+stream['credentials']['username']+':')    
            password = stream['credentials']['password']

        credentials = stream['credentials']

        # Process the list of tokens to create
        if self._permission_create:
            try:
                to_create = stream[self._type.name]['to_create']
                for i in range(len(to_create)):
                    if self._type is Type.rsync_tasks:
                        to_create[i]['rsync_user'] = credentials['username']
                    self.create(json.dumps(to_create[i]), credentials)
            except Exception:
                if not self._quiet:
                    print("Nothing to create ... ")

        # Process the list of tokens to update
        if self._permission_update:
            try:
                to_update = stream[self._type.name]['to_update']
                for i in range(len(to_update)):
                    my_id = to_update[i]['id']
                    if self._type is Type.rsync_tasks:
                        to_update[i]['rsync_user'] = credentials['username']
                    self.update(json.dumps(to_update[i]), credentials, my_id)
            except Exception:
                if not self._quiet:
                    print("Nothing to update ... ") 


        # Process the list of tokens to delete
        if self._permission_delete:
            try:
                to_delete = stream[self._type.name]['to_delete']
                for i in range(len(to_delete)):
                    my_id = to_delete[i]['id']
                    self.delete(credentials, my_id)
            except Exception:
                if not self._quiet:
                    print("Nothing to delete ... ")

        if not self._quiet:
            print("Finished processing", self._config_file_name)

    def get_credentials(self):
        if not self._quiet:
            print("Getting credentials ...")

        stream_file = open(os.path.join(os.path.dirname(__file__), self._config_file_name), 'r')
        stream = yaml.load(stream_file)
        stream_file.close()

        # Check for password, if empty -> prompt user
        try:
            password = stream['credentials']['password']
        except Exception:
            stream['credentials']['password'] = getpass.getpass('Enter the password for '+stream['credentials']['username']+':')    
            password = stream['credentials']['password']

        credentials = stream['credentials']
        
        return stream['credentials']

    def determine_type(self):
        if not self._quiet:
            print("Determining type ... ", end='')
        stream_file = open(os.path.join(os.path.dirname(__file__), self._config_file_name), 'r')
        stream = yaml.load(stream_file)
        stream_file.close()

        try:
            if stream[Type.rsync_tasks.name]:
                self._type = Type.rsync_tasks
                self._base_address = self._base_address+'%s' % self._rsync_address
                if not self._quiet:
                    print("Type is", self._type)
                return True
        except Exception:
            pass

        try:
            if stream[Type.users.name]:
                self._type = Type.users
                self._base_address = self._base_address+'%s' % self._user_address
                if not self._quiet:
                    print("Type is", self._type)
                return True
        except Exception:
            pass

        try:
            if stream[Type.groups.name]:
                self._type = Type.groups
                self._base_address = self._base_address+'%s' % self._group_address
                if not self._quiet:
                    print("Type is", self._type)
                return True
        except Exception:
            pass

        return False

    def delete_all_tasks(self, credentials):
        self._base_address = 'http://%s/api/v1.0%s' % (self._hostname, self._rsync_address)
        self._type = Type.task
        if input("Are you sure you want to delete all rsync tasks? y/[n]: ") is 'y':
            if not self._quiet:
                print("Deleting all tasks ...")
            current_tasks = self.get_all_tasks(credentials)
            for i in range(len(current_tasks)):
                my_id = current_tasks[i]['id']
                self.delete(credentials, my_id)

    def delete_all_users(self, credentials):
        self._base_address = 'http://%s/api/v1.0%s' % (self._hostname, self._user_address)
        self._type = Type.users
        if input("Are you sure you want to delete all users? y/[n]: ") is 'y':
            if not self._quiet:
                print("Deleting all users ...")
            current_users = self.get_all_non_builtin_users(credentials)

            for i in range(len(current_users)):
                my_id = current_users[i]['id']
                self.delete(credentials, my_id)

    def delete_all_groups(self, credentials):
        self._base_address = 'http://%s/api/v1.0%s' % (self._hostname, self._group_address)
        self._type = Type.groups
        if input("Are you sure you want to delete all groups? y/[n]: ") is 'y':
            if not self._quiet:
                print("Deleting all groups ...")
            current_groups = self.get_all_non_builtin_groups(credentials)

            for i in range(len(current_groups)):
                my_id = current_groups[i]['id']
                self.delete(credentials, my_id)

    def get_all_tasks(self, credentials):
        return json.loads(requests.get(
            'http://%s/api/v1.0%s/' % (self._hostname, self._rsync_address),
            auth=(credentials['username'], credentials['password']),
            headers={'Content-Type': 'application/json'},
            verify=False,
            data=''
            ).text)

    def get_all_users(self, credentials):
        return json.loads(requests.get(
            'http://%s/api/v1.0%s/' % (self._hostname, self._user_address),
            auth=(credentials['username'], credentials['password']),
            headers={'Content-Type': 'application/json'},
            verify=False,
            data=''
            ).text)

    def get_all_non_builtin_users(self, credentials):
        r = json.loads(requests.get(
            'http://%s/api/v1.0%s/' % (self._hostname, self._user_address),
            auth=(credentials['username'], credentials['password']),
            headers={'Content-Type': 'application/json'},
            verify=False,
            data=''
            ).text)
        t = []
        for i in r:
            if i['bsdusr_builtin'] is False:
                t.append(i)
        return t

    def get_all_groups(self, credentials):
        return json.loads(requests.get(
            'http://%s/api/v1.0%s/' % (self._hostname, self._group_address),
            auth=(credentials['username'], credentials['password']),
            headers={'Content-Type': 'application/json'},
            verify=False,
            data=''
            ).text)

    def get_all_non_builtin_groups(self, credentials):
        r = json.loads(requests.get(
            'http://%s/api/v1.0%s/' % (self._hostname, self._group_address),
            auth=(credentials['username'], credentials['password']),
            headers={'Content-Type': 'application/json'},
            verify=False,
            data=''
            ).text)
        t = []
        for i in r:
            if i['bsdgrp_builtin'] is False:
                t.append(i)
        return t

# config = the name of the config file (yaml), quiet
def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument('-H', '--hostname', required=False, type=str)
    parser.add_argument('-co', '--config', required=False, type=str)
    parser.add_argument('-q', '--quiet', required=False, type=str)
    parser.add_argument('-c', '--create', required=False, type=str)
    parser.add_argument('-up', '--update', required=False, type=str)
    parser.add_argument('-d', '--delete', required=False, type=str)
    parser.add_argument('-dat','--delete_all_tasks', required=False, type=str)
    parser.add_argument('-dau','--delete_all_users', required=False, type=str)
    parser.add_argument('-dag','--delete_all_groups', required=False, type=str)
    parser.add_argument('-diag','--display_groups', required=False, type=str)

    args = parser.parse_args(sys.argv[1:])

    hostname = args.hostname
    # hostname = '192.168.0.46'
    config_file_name = args.config
    quiet, create, update, delete = False, True, False, False

    # Add three booleans and test for create, update and delete, if they aren't there default to false
    if args.quiet is None:
        quiet = False
    elif args.quiet is 't' or args.quiet is 'true':
        quiet = True

    if args.create is None:
        create = False
    elif args.create is 't' or args.create is 'true':
        create = True

    if args.update is None:
        update = False
    elif args.update is 't' or args.update is 'true':
        update = True

    if args.delete is None:
        delete = False
    elif args.delete is 't' or args.delete is 'true':
        delete = True

    # Create a manager to process the config file
    manager =  FreeNASManager(hostname,config_file_name, quiet, create, update, delete)
    if args.delete_all_tasks or args.delete_all_users or args.delete_all_groups:
        if args.delete_all_tasks is 't':
            # Get real credentials from the file before doing this (or prompt for credentials?)
            manager.delete_all_tasks(manager.get_credentials()) 
        if args.delete_all_groups is 't':
            # Get real credentials from the file before doing this (or prompt for credentials?)
            manager.delete_all_groups(manager.get_credentials()) 
        if args.delete_all_users is 't':
            manager.delete_all_users(manager.get_credentials()) 

    elif args.display_groups:
        if args.display_groups is 't':
            print(manager.get_all_non_builtin_groups(manager.get_credentials()))
    else:
        manager.display_configuration()
        if manager.determine_type():
            manager.process_config_file()

if __name__ == '__main__':
    main(sys.argv[1:])
