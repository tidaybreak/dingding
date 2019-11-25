#!/system/bin/sh

#一直保持唤醒状态，不进入睡眠 让手机即使黑屏也不进入睡眠模式 echo aaa > /sys/power/wake_unlock
echo aaa > /sys/power/wake_lock 

function random()
{
	
    min=$1;
    max=`expr $2 - $1`;
    num=$RANDOM;
    ((retnum=num%max+min));
    echo $retnum;
}

out=$(random $1 $2);
busybox echo `date` "reboot after:"$out >> /sdcard/log/reboot.log
sleep $out;
busybox echo `date` "run to reboot after:"$out >> /sdcard/log/reboot.log
sleep 3;
reboot;