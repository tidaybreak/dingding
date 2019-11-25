#!/system/bin/sh

function random()
{
    min=$1;
    max=`expr $2 - $1`;
    num=$RANDOM;
    ((retnum=num%max+min));
    echo $retnum;
}


out=$(random $1 $2);
sleep $out;
sleep 3;

input keyevent 82
sleep 3;
am force-stop com.alibaba.android.rimet
sleep 2;
#am start -n com.alibaba.android.rimet/.biz.home.activity.HomeActivity
am start -n com.alibaba.android.rimet/.biz.SplashActivity
sleep 15;

#有更新时操作
input tap 454 750

#点密码
input tap 280 610
input text "wzt19860801"
#输完密码要两次回车
input keyevent 66
input keyevent 66
sleep 15;

input keyevent 26