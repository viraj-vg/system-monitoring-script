# System Monitoring Script

Simple bash script to check CPU, RAM and Disk usage on the system, show top CPU-consuming processes, 
and log alerts if something crosses the limit.

## What it does

- Checks load average
- Checks CPU usage
- Checks RAM/Swap usage
- Checks disk space
- Shows top 5 CPU consuming processes
- If any of CPU/RAM/Disk go above the limit, it prints a warning and also saves it in alert.log with date/time

## Why I wrote the code this way

**CPU usage:**
```bash
cpu_usage=$(top -bn1 | grep "%Cpu(s)" | awk '{print int(100-$8)}')
```
top normally keeps updating live, so `-bn1` makes it run just once and give output as plain text. 
Then I grep the CPU line and take column 8, which is idle%. Since we want used% not idle%, just do 100 - idle. 
int() is there so we don't get decimal values, easier to compare in if condition.

**Memory usage:**
```bash
mem_usage=$(free | grep "Mem" | awk '{print int($3/$2*100)}')
```
free command shows memory in KB. column 2 is total, column 3 is used. used/total*100 gives percentage. Simple.

**Disk usage:**
```bash
disk_space=$(df -h / | awk 'NR==2 {print $5}' | tr -d "%")
```
df -h shows disk info, 2nd line has the actual numbers (1st line is just headers). 
column 5 is use%. Had to remove the % symbol using tr because bash can't compare numbers if % is stuck to it, 
it'll throw error in the if condition.

**Why -gt and not >:**
In bash, `>` is used for redirecting output to a file, not for comparison. 
So for comparing numbers we need -gt (greater than), -lt (less than) etc.

**Top CPU processes:**
```bash
ps -eo pid,comm,%cpu --sort=-%cpu | head -6
```
ps -eo lets you pick which columns to show (pid, process name, cpu%). 
--sort=-%cpu sorts highest first (the - means descending). head -6 takes header + top 5 rows.

## Continuous monitoring (while loop)

Earlier I was running this using:
```bash
watch -n 5 ./system_monitor.sh
```
Changed it to use a built-in while loop instead, 
so the script doesn't depend on external watch command (not all systems have it installed by default):
```bash
while true
do
    ...
    sleep 5
done
```
sleep 5 so it don't run continuously without break and eat up CPU. 
clear is there so each time it shows only latest reading, 
otherwise terminal keeps filling up with old outputs and hard to read.

## How to run

```bash
chmod +x system_monitor.sh
./system_monitor.sh
```
Runs every 5 sec continuously till you stop it.

## How to stop

If running normally in terminal, just Ctrl + C

If running in background:
```bash
ps aux | grep system_monitor.sh
kill <PID>
```

## Alert limits

- CPU usage > 55%
- Memory usage > 80%
- Disk usage > 85%

(can change these numbers directly in script if needed)

## Sample Output

<img width="365" height="271" alt="image" src="https://github.com/user-attachments/assets/1aac6ae6-12ae-47df-bde4-62efa79394a7" />




Sample alert.log entry when threshold is crossed:

<img width="274" height="70" alt="image" src="https://github.com/user-attachments/assets/8a1661a0-71ef-47ea-8b2c-712c6d893f57" />



## Files

- system_monitor.sh - the script
- alert.log - auto created, stores alert history

## Changelog

v1.2 - added top 5 CPU consuming processes

v1.1 - added while loop for continuous monitoring instead of using watch command, added sleep 5 and clear

v1.0 - first version, basic one time check for cpu/mem/disk
