#!/bin/bash

# List of remote servers
servers=("192.168.1.101" "192.168.1.102")
ssh_user="your_ssh_user"

# Function to get high CPU and memory usage of JVM threads
get_jvm_usage() {
    local server=$1
    echo "Connecting to $server..."

    # Find WebSphere JVM process ID
    jvm_pid=$(ssh ${ssh_user}@${server} "ps -eo pid,cmd | grep -i 'WebSphere' | grep -i 'java' | grep -v 'grep' | awk '{print \$1}'")
    
    if [ -z "$jvm_pid" ]; then
        echo "No WebSphere JVM process found on $server."
        return
    fi

    echo "WebSphere JVM process ID on $server: $jvm_pid"

    # Get high CPU and memory usage of JVM threads
    thread_usage=$(ssh ${ssh_user}@${server} "top -b -n1 -H -p $jvm_pid | grep java | awk '{print \$1, \$9, \$10, \$12}' | sort -k2nr | head -n 10")

    echo "High CPU and memory usage of JVM threads on $server:"
    echo "$thread_usage"
    echo
}

# Iterate over the list of servers and get JVM usage
for server in "${servers[@]}"; do
    get_jvm_usage $server
done
