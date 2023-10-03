
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Spark job failures due to cluster resource contentions.
---

This incident type refers to a situation where Spark jobs are failing due to resource contentions in the cluster. When multiple Spark jobs are trying to access the same resources or data at the same time, it can cause a bottleneck that leads to job failures. This can happen when the resources in the cluster are not properly allocated or when the number of jobs running simultaneously exceeds the cluster's capacity to handle them. The result is that Spark jobs fail, leading to disruptions in data processing and analysis.

### Parameters
```shell
export JOB_ID="PLACEHOLDER"

export NUM_NODES="PLACEHOLDER"

export LOG_FILE="PLACEHOLDER"

export NEW_CPU_VALUE="PLACEHOLDER"

export CLUSTER_PROCESS_NAME="PLACEHOLDER"

export NEW_MEMORY_VALUE="PLACEHOLDER"
```

## Debug

### Get the status of the Spark cluster
```shell
spark-status
```

### Check the resource usage of the Spark jobs
```shell
yarn application -status ${JOB_ID}
```

### Check if any nodes in the cluster are overloaded
```shell
top -d 1 -b | grep -E '(Cpu|Memory)' | head -n ${NUM_NODES}
```

### Analyze the Spark logs for any errors or exceptions
```shell
grep -i -e 'error' -e 'exception' ${LOG_FILE}
```

### Check the network usage of the cluster nodes
```shell
netstat -s | grep -E 'segments retransmitted' | head -n ${NUM_NODES}
```

### Not enough resources allocated to the Spark job causing it to compete with other jobs running on the cluster.
```shell
bash

#!/bin/bash



# Set the parameters

SPARK_JOB=${JOB_ID}

CLUSTER=${CLUSTER_PROCESS_NAME}



# Check the resource allocation for the Spark job

allocated_resources=$(grep $SPARK_JOB /var/log/spark-resource-manager.log | grep "Allocated resources")

if [ -z "$allocated_resources" ]; then

  echo "No allocation found for the Spark job $SPARK_JOB"

  exit 1

fi



# Check the total available resources in the cluster

total_resources=$(grep $CLUSTER /var/log/spark-resource-manager.log | grep "Total resources")

if [ -z "$total_resources" ]; then

  echo "No resource information found for the cluster $CLUSTER"

  exit 1

fi



# Parse the allocated and total resources

allocated_cpu=$(echo $allocated_resources | awk '{print $5}')

allocated_memory=$(echo $allocated_resources | awk '{print $7}')

total_cpu=$(echo $total_resources | awk '{print $5}')

total_memory=$(echo $total_resources | awk '{print $7}')



# Check if the allocated resources are less than the total resources

if [ $allocated_cpu -lt $total_cpu ] && [ $allocated_memory -lt $total_memory ]; then

  echo "The Spark job $SPARK_JOB is not allocated enough resources"

else

  echo "The Spark job $SPARK_JOB has enough resources"

fi


```

## Repair

### Increasing the resources allocated to the cluster, like memory and CPU, to avoid contention.
```shell
bash

#!/bin/bash



# Set the new values for memory and CPU

NEW_MEMORY=${NEW_MEMORY_VALUE}

NEW_CPU=${NEW_CPU_VALUE}



# Find the PID of the cluster process

PID=$(ps aux | grep ${CLUSTER_PROCESS_NAME} | grep -v grep | awk '{print $2}')



# Increase the memory and CPU limits for the cluster process

sudo renice -n -10 $PID

sudo cpulimit -p $PID -l $NEW_CPU &

sudo cgroups -g memory:cluster_group_name/ -m $NEW_MEMORY"m" $PID


```