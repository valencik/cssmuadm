import sys
import json
import requests

# GET       /api/v1.0/tasks/rsync/              :   Returns a list of all rsyncs.
# POST      /api/v1.0/tasks/rsync/              :   Creates a new rsync and returns the new rsync object.
# POST      /api/v1.0/tasks/rsync/(int: id)/run/:   Runs the rsync task with id
# PUT       /api/v1.0/tasks/rsync/(int: id)/    :   Updates the rsync task with id
# DELETE    /api/v1.0/tasks/rsync/(int: id)/    :   Deletes the rsync task with id 

def get_rsync_tasks(hostname, username, password):
    base_address =  'http://%s/api/v1.0' % hostname 
    resource_request = 'tasks/rsync'
    params = ''

    rsync_task_list = requests.get(
        '%s/%s/' % (base_address, resource_request),
        auth=(username, password),
        headers={'Content-Type': 'application/json'},
        verify=False,
        data=params,
    )

    # print("Rsync Task List:")
    # print(rsync_task_list.status_code)
    # print(rsync_task_list.json)
    # print(rsync_task_list.text)

    return rsync_task_list

def get_rsync_task(hostname, username, password, taskId):
    tasks = json.loads(get_rsync_tasks(hostname, username, password).text)
    for i in range(len(tasks)):
        if tasks[i]['id'] is taskId:
            return tasks[i]

def get_rsync_ids(rsync_task_list):
    ids = []

    jd = json.loads(rsync_task_list.text)
    for i in range(len(jd)):
        ids.append(jd[i]['id'])

    return ids

def create_new_rsync(hostname, username, password, module = 'TestModule'):
    base_address =  'http://%s/api/v1.0' % hostname 
    resource_request = 'tasks/rsync'
    path = '/mnt/Disk1'
    # module = 'TestModule'
    remotehost = 'cs.smu.ca'

    minutes = '*/20'    
    hours = '*/2'       
    months = '2'         
    daysOfWeek = '*'     
    daysOfMonth = '*/2'    

    params = json.dumps({
            "rsync_path": path,
            "rsync_user": username,
            "rsync_mode": "module",
            "rsync_remotemodule": module,
            "rsync_remotehost": remotehost,
            "rsync_direction": "push",
            "rsync_minute": minutes,
            "rsync_hour": hours,
            "rsync_daymonth": daysOfMonth,
            "rsync_month": months,
            "rsync_dayweek": daysOfWeek,
        })

    new_rsync_task = requests.post(
        '%s/%s/' % (base_address, resource_request),
        auth=(username, password),
        headers={'Content-Type': 'application/json'},
        verify=False,
        data=params,
    )

    # print("Newly Created Rsync Task:")
    print(new_rsync_task.status_code)
    # print(new_rsync_task.json)
    print(new_rsync_task.text)

    return new_rsync_task

def delete_rsync_task(hostname, username, password, taskId):
    base_address =  'http://%s/api/v1.0' % hostname 
    resource_request = 'tasks/rsync/'
    params = ''

    deleted_rsync_task = requests.delete(
        '%s/%s/%s' % (base_address, resource_request, taskId),
        auth=(username, password),
        headers={'Content-Type': 'application/json'},
        verify=False,
        data=params,
    )

    # print("Rsync Task List:")
    # print(deleted_rsync_task.status_code)
    # print(deleted_rsync_task.json)
    # print(deleted_rsync_task.text)

    return deleted_rsync_task

def update_rsync_task(hostname, username, password, taskId):


    base_address =  'http://%s/api/v1.0' % hostname 
    resource_request = 'tasks/rsync/'
    params = {
          "rsync_archive": True
    }

    updated_rsync_task = requests.put(
        '%s/%s/%s' % (base_address, resource_request, taskId),
        auth=(username, password),
        headers={'Content-Type': 'application/json'},
        verify=False,
        data=params,
    )

    # print("Rsync Task List:")
    # print(updated_rsync_task.status_code)
    # print(updated_rsync_task.json)
    # print(updated_rsync_task.text)

    return updated_rsync_task

def main(argv):
    hostname = '192.168.1.113'
    username = 'root'
    password = 'admin'

    # create_new_rsync(hostname,  username, password)
    # get_rsync_tasks(hostname,   username, password)
    # delete_rsync_task(hostname, username, password, 1)
    # update_rsync_task(hostname, username, password, 1)

    task = create_new_rsync(hostname, username, password, "ModuleName")

    # ids = get_rsync_ids(get_rsync_tasks(hostname, username, password))
    # for i in range(len(ids)):
    #     print(get_rsync_task(hostname, username, password, ids[i]))
    
    # task = get_rsync_task(hostname, username, password, 9)
    # print(task)

if __name__ == "__main__":
   main(sys.argv[1:])