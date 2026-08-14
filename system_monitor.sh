#!/bin/bash

#Maintainer june2026
#This script use for monitoring and alerting

while true
do
    clear
    echo "Monitoring Started"
    echo "Time: $(date)"

echo "##################################################################"

        echo "Checking Load Average"
	uptime

echo "##################################################################"



	echo "Checking CPU Usage"

	cpu_usage=$(top -bn1 | grep "%Cpu(s)" | awk '{print int(100-$8)}')

	echo "$cpu_usage%"

	if [ "$cpu_usage" -gt 55 ] 
	then
		echo "Cpu usage is high"
        	echo "$(date) : Cpu usage is high" >> alert.log
	else 
		echo "Cpu usage is normal"
	fi 


echo "##################################################################"

	echo "Check RAM & Swap"
	mem_usage=$(free | grep "Mem" | awk '{print int($3/$2*100)}')
	echo "$mem_usage%"
	if [ "$mem_usage" -gt 80 ]
	then
        	echo "Low memory"
        	echo "$(date) : Low memory" >> alert.log

	else
        	echo "Having free memory space"
	fi

echo "##################################################################"



	echo "Check Disk Space"
	disk_space=$(df -h / | awk 'NR==2 {print $5}' | tr -d "%")

	echo "used disk space = $disk_space%"


	if [ "$disk_space" -gt 85 ]
	then
		echo "Disk Space is full"
        	echo "$(date) : Disk Space is full" >> alert.log

	else
		echo "System have free disk space"
	fi

echo "##################################################################"


	echo "Top 5 CPU consuming processes"
	ps -eo pid,comm,%cpu --sort=-%cpu | head -6


echo "##################################################################"


	echo "Execution Completed. Checking again in 05 seconds..."
	sleep 5
done
