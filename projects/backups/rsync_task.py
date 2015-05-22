import json
import requests
import sys

# GET   /api/v1.0/tasks/rsync/  :   Returns a list of all rsyncs.
# POST  /api/v1.0/tasks/rsync/  :   Creates a new rsync and returns the new rsync object.

def get_rsync_tasks(hostname, username, password):
    base_address =  'http://%s/api/v1.0' % hostname 
    resource_request = 'tasks/rsync'
    params = ''

    print('%s/%s/' % (base_address, resource_request))

    rsync_task_list = requests.get(
        '%s/%s/' % (base_address, resource_request),
        auth=(username, password),
        headers={'Content-Type': 'application/json'},
        verify=False,
        data=params,
    )

    print("Rsync Task List:")
    # print(rsync_task_list.status_code)
    # print(rsync_task_list.json)
    print(rsync_task_list.text)

def create_new_rsync(hostname, username, password):
    base_address =  'http://%s/api/v1.0' % hostname 
    resource_request = 'tasks/rsync'
    path = "/mnt/Disk1"

    params = json.dumps({
            "rsync_path": path,
            "rsync_user": username,
            "rsync_mode": "module",
            "rsync_remotemodule": "testmodule",
            "rsync_remotehost": "testhost",
            "rsync_direction": "push",
            "rsync_minute": "*/20",
            "rsync_hour": "*",
            "rsync_daymonth": "*",
            "rsync_month": "*",
            "rsync_dayweek": "*",
        })

    new_rsync_task = requests.post(
        '%s/%s/' % (base_address, resource_request),
        auth=(username, password),
        headers={'Content-Type': 'application/json'},
        verify=False,
        data=params,
    )

    print("Newly Created Rsync Task:")
    # print(rsync_task_list.status_code)
    # print(rsync_task_list.json)
    print(new_rsync_task.text)

def main(argv):
    create_new_rsync('192.168.1.113', 'root', 'admin')
    # get_rsync_tasks('192.168.1.113', 'root', 'admin')

if __name__ == "__main__":
   main(sys.argv[1:])