import sys
import argparse
import json
import requests
import yaml
import os
    
class RsyncManager(object):

    def __init__(self, hostname, config_file_name, quiet = False, create = False, update = False, delete = False):
        self._hostname = hostname
        self._quiet = quiet
        self._config_file_name = config_file_name
        self._permission_create = create
        self._permission_update = update
        self._permission_delete = delete
        self._base_address = 'http://%s/api/v1.0/tasks/rsync' % hostname


    def process_config_file(self):
        if not self._quiet:
            print("Starting to process", self._config_file_name)
        stream = open(os.path.join(os.path.dirname(__file__), self._config_file_name), 'r')
        stream = yaml.load(stream)

        credentials = stream['credentials']
        rsync_tasks_to_create = stream['rsync_tasks_to_create']
        rsync_tasks_to_update = stream['rsync_tasks_to_update']
        rsync_tasks_to_delete = stream['rsync_tasks_to_delete']

        if self._permission_create:
            for i in range(len(rsync_tasks_to_create)):
                task = 'task' + str(i)
                rsync_tasks_to_create[task]['rsync_user'] = credentials['username']
                self.create_rsync_task(json.dumps(rsync_tasks_to_create[task]), credentials)

        if self._permission_update:
            for i in range(len(rsync_tasks_to_update)):
                task = 'task' + str(i)
                rsync_tasks_to_update[task]['rsync_user'] = credentials['username']
                self.update_rsync_task(json.dumps(rsync_tasks_to_update[task]), credentials)

        if self._permission_delete:
            for i in range(len(rsync_tasks_to_delete)):
                task = 'task' + str(i)
                rsync_tasks_to_delete[task]['rsync_user'] = credentials['username']
                self.delete_rsync_task(json.dumps(rsync_tasks_to_delete[task]['id']), credentials)

    def create_rsync_task(self, params, credentials):
        if not self._quiet:
            print("Creating rsync task ...")

        new_rsync_task = requests.post(
            '%s/' % self._base_address,
            auth=(credentials['username'], credentials['password']),
            headers={'Content-Type': 'application/json'},
            verify=False,
            data=params,
        )

        if not self._quiet:
            print("Rsync task was created for user:", credentials['username'])
        return new_rsync_task

    def update_rsync_task(self, params, credentials):
        if not self._quiet:
            print("Updating rsync task ...")

        if not self._quiet:
            print("Rsync task was updated for user:", credentials['username'])

    def delete_rsync_task(self, id, credentials):
        if not self._quiet:
            print("Deleting rsync task ...")

        if not self._quiet:
            print("Rsync task was deleted for user:", credentials['username'])

    def run_task(self, id, credentials):
        if not self._quiet:
            print("Running rsync task ...")

    def get_rsync_tasks(self,hostname, credentials):
        base_address =  'http://%s/api/v1.0' % hostname 
        resource_request = 'tasks/rsync'
        params = ''

        rsync_task_list = requests.get(
            '%s/%s/' % (base_address, resource_request),
            auth=(credentials['username'], credentials['password']),
            headers={'Content-Type': 'application/json'},
            verify=False,
            data=params,
        )

        return rsync_task_list

# config = the name of the config file (yaml), quiet
def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument('-H', '--hostname', required=False, type=str)
    parser.add_argument('-co', '--config', required=False, type=str)
    parser.add_argument('-q', '--quiet', required=False, type=str)
    parser.add_argument('-c', '--create', required=False, type=str)
    parser.add_argument('-up', '--update', required=False, type=str)
    parser.add_argument('-d', '--delete', required=False, type=str)

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
        create = True
    elif args.create is 't' or args.create is 'true':
        create = True
    elif args.create is 'f' or args.create is 'false':
        create = False

    if args.update is None:
        update = False
    elif args.update is 't' or args.update is 'true':
        update = True

    if args.delete is None:
        delete = False
    elif args.delete is 't' or args.delete is 'true':
        delete = True

    # Create an rsync manager to process the config file: It will process the tasks and will create, 
    # update (not implemented) or delete (not fully implemented) tasks
    rman =  RsyncManager(hostname,config_file_name, quiet, create, update, delete)
    rman.process_config_file()

if __name__ == '__main__':
    main(sys.argv[1:])
