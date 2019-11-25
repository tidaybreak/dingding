#!/system/bin/sh

#一直保持唤醒状态，不进入睡眠 让手机即使黑屏也不进入睡眠模式 echo aaa > /sys/power/wake_unlock
echo aaa > /sys/power/wake_lock
#提示为“未检测到任何互联网连接 因此不会自动重新连接”问题
settings put global captive_portal_detection_enabled 0
busybox echo `date` "lauch:" >> /sdcard/log/reboot.log
