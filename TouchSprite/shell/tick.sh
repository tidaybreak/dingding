#!/system/bin/sh
PATH=$PATH:/data/data/berserker.android.apps.sshdroid/home/.bin/

cd /storage/emulated/legacy/shell/
battery=`dumpsys battery`
#battery=`dumpsys battery|grep level|awk '{print $2}'`
echo $battery > battery.log
curl -d "data=$battery" http://www.tiham.com/api/dd.php
#curl -X POST --data-urlencode "data=$battery" http://www.tiham.com/api/dd.php
#wget http://www.tiham.com/api/dd.php?data="$battery"