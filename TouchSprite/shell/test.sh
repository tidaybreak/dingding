#!/system/bin/sh

echo  on>/sys/power/state
busybox echo `date` "reboot after:" >> /sdcard/log/reboot.log
busybox sleep 10;
busybox echo `date` "run to reboot after:" >> /sdcard/log/reboot.log

