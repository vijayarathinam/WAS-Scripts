Ansible script that retrieves high CPU and memory usage of Java threads from a WebSphere Application Server JVM running on two Linux machines

Ensure proper access: Ensure the necessary permissions and tools (such as jstat, jstack, or other JVM monitoring tools) are available on the remote machines.
Inventory File: List the two Linux machines.
Playbook: Write an Ansible playbook to gather the CPU and memory usage information.
Below is an example Ansible playbook to accomplish this task.

Prerequisites
Ensure you have Ansible installed on your control machine.
Ensure SSH access to the remote servers from the control machine.
Ensure the user running the playbook has the necessary permissions to monitor JVM processes.
Ansible Inventory File
Create an inventory file (e.g., inventory.ini) listing the IP addresses or hostnames of your remote 

[jvm_servers]
server1 ansible_host=192.168.1.101 ansible_user=your_ssh_user
server2 ansible_host=192.168.1.102 ansible_user=your_ssh_user


Ansible Playbook
Create an Ansible playbook (e.g., get_jvm_usage.yml) to gather high CPU and memory usage of Java threads:

---
- name: Get high CPU and memory usage of Java threads from WebSphere JVM
  hosts: jvm_servers
  become: yes
  tasks:
    - name: Find WebSphere JVM process ID
      shell: |
        ps -eo pid,cmd | grep -i 'WebSphere' | grep -i 'java' | grep -v 'grep' | awk '{print $1}'
      register: jvm_pids

    - name: Ensure a JVM process is found
      fail:
        msg: "No WebSphere JVM process found."
      when: jvm_pids.stdout == ""

    - name: Get high CPU and memory usage of JVM threads
      shell: |
        pid={{ jvm_pids.stdout }}
        top -b -n1 -H -p $pid | grep java | awk '{print $1, $9, $10, $12}' | sort -k2nr | head -n 10
      register: thread_usage

    - name: Print high CPU and memory usage of JVM threads
      debug:
        msg: "High CPU and memory usage of JVM threads on {{ inventory_hostname }}:\n{{ thread_usage.stdout }}"


Explanation
Inventory File (inventory.ini):

Lists the remote servers under the group jvm_servers.
Specifies the SSH user for Ansible to connect to each server.
Playbook (get_jvm_usage.yml):

Targets the jvm_servers group defined in the inventory file.
Uses become: yes to gain elevated privileges on the remote servers (assuming the SSH user can sudo without a password, or modify as needed).
Finds the WebSphere JVM process ID using the ps command and captures it in the jvm_pids variable.
Fails the playbook if no JVM process is found.
Retrieves the high CPU and memory usage of JVM threads using top, sorts the output by CPU usage, and captures the top 10 threads.
Prints the high CPU and memory usage of JVM threads using the debug module.
Running the Playbook
Execute the playbook using the following command:

ansible-playbook -i inventory.ini get_jvm_usage.yml


Note
Adjust the commands and filters in the shell tasks as necessary to fit your specific WebSphere setup and monitoring tools available.
Ensure the user running the playbook has the necessary permissions to monitor JVM processes and gather system resource usage information.


