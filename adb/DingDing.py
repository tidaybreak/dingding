# -*- coding: utf-8 -*-
import subprocess
import time
import sys
import sched
import datetime
import random
import smtplib
import base64
from email.header import Header
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication
import configparser
import cv2
from queue import Queue
import threading
import psutil
import os
import signal

config = configparser.ConfigParser(allow_no_value=False)
config.read("dingding.cfg")
scheduler = sched.scheduler(time.time,time.sleep)
go_hour = int(config.get("time","go_hour"))
back_hour = int(config.get("time","back_hour"))
directory = config.get("ADB","directory")
sender = config.get("email","sender")
psw = config.get("email","psw")
smtp = config.get("email","smtp")
receive = config.get("email","receive")
warnmail = config.get("email","warnmail")
screen_dir = config.get("screen","screen_dir")


def rand_sleep(min, max):
    sleeptime = random.randint(min, max)
    time.sleep(sleeptime)

# 打开钉钉，关闭钉钉封装为一个妆饰器函数
def with_open_close_dingding(func):
    def wrapper(self, *args, **kwargs):
        print("打开钉钉")
        # 开启新线程
        q = Queue()
        t1 = threading.Thread(target=start_video,args=(q,))
        t1.start()
        operation_list = [self.start_server, self.adbpower, self.adbpower, self.adbkill_dingding, self.adbopen_dingding]
        for operation in operation_list:
            process = subprocess.Popen(operation, shell=False,stdout=subprocess.PIPE)
            process.wait()
        # 确保完全启动，并且加载上相应按键
        rand_sleep(10, 20)
        print("open dingding success")
        print("打开打卡界面")
        operation_list1 = [self.adbselect_work, self.adbselect_playcard]
        for operation in operation_list1:
            process = subprocess.Popen(operation, shell=False,stdout=subprocess.PIPE)
            process.wait()
            rand_sleep(5, 10)
        rand_sleep(1, 20)
        print("open playcard success")
        # 包装函数
        
        func(self, *args, **kwargs)
        print("关闭钉钉")
        operation_list2 = [self.adbback_index, self.adbkill_dingding]
        for operation in operation_list2:
            process = subprocess.Popen(operation, shell=False,stdout=subprocess.PIPE)
            process.wait()
        print("kill dingding success")
        # 发送命令结束线程
        q.put(1)
        t1.join()
    return wrapper


class dingding:

    # 初始化，设置adb目录
    def __init__(self,directory):
        self.directory = directory
        # 重启adb服务进程
        self.start_server = '"%s\\adb" start-server' % directory        
        # 点亮屏幕
        self.adbpower = '"%s\\adb" shell input keyevent 26' % directory
        # 滑屏解锁
        self.adbclear = '"%s\\adb" shell input swipe %s' % (directory,config.get("position","light_position"))
        # 启动钉钉应用
        self.adbopen_dingding = '"%s\\adb" shell monkey -p com.alibaba.android.rimet -c android.intent.category.LAUNCHER 1' %directory
        # 关闭钉钉
        self.adbkill_dingding = '"%s\\adb" shell am force-stop com.alibaba.android.rimet'% directory
        # 返回桌面
        self.adbback_index = '"%s\\adb" shell input keyevent 3' % directory
        # 点击工作
        self.adbselect_work = '"%s\\adb" shell input tap %s' % (directory,random_coord(config.get("position","work_position"), 10))
        # 点击考勤打卡
        self.adbselect_playcard = '"%s\\adb" shell input tap %s' % (directory,random_coord(config.get("position","check_position"), 10))
        # 点击下班打卡
        self.adbclick_playcard = '"%s\\adb" shell input tap %s' % (directory,random_coord(config.get("position","play_position"), 10))
        # 设备截屏保存到sdcard
        self.adbscreencap = '"%s\\adb" shell screencap -p sdcard/screen.png' % directory
        # 传送到计算机
        self.adbpull = '"%s\\adb" pull sdcard/screen.png %s' % (directory,screen_dir)
        # 删除设备截屏
        self.adbrm_screencap = '"%s\\adb" shell rm -r sdcard/screen.png' % directory


    # 点亮屏幕 》》解锁 》》打开钉钉
    def open_dingding(self):
        operation_list = [self.adbpower,self.adbclear,self.adbopen_dingding]
        for operation in operation_list:
            process = subprocess.Popen(operation, shell=False,stdout=subprocess.PIPE)
            process.wait()
        # 确保完全启动，并且加载上相应按键
        time.sleep(20)
        print("open dingding success")


    # 返回桌面 》》 退出钉钉 》》 手机黑屏
    def close_dingding(self):
        operation_list = [self.adbback_index,self.adbkill_dingding,self.adbpower]
        for operation in operation_list:
            process = subprocess.Popen(operation, shell=False,stdout=subprocess.PIPE)
            process.wait()
        print("kill dingding success")


    # 上班(极速打卡)
    @with_open_close_dingding
    def goto_work(self,minute):
        self.screencap()
        time.sleep(40)
        self.sendEmail(minute)
        print("打卡成功")

    # 打开打卡界面
    def openplaycard_interface(self):
        print("打开打卡界面")
        operation_list = [self.adbselect_work, self.adbselect_playcard]
        for operation in operation_list:
            process = subprocess.Popen(operation, shell=False,stdout=subprocess.PIPE)
            process.wait()
            time.sleep(2)
        time.sleep(30)
        print("open playcard success")

    # 下班
    @with_open_close_dingding
    def after_work(self,minute):
        operation_list = [self.adbclick_playcard]
        for operation in operation_list:
            process = subprocess.Popen(operation, shell=False,stdout=subprocess.PIPE)
            process.wait()
            time.sleep(3)
        time.sleep(40)
        self.screencap()
        self.sendEmail(minute)
        print("afterwork playcard success")

    # 截屏>> 发送到电脑 >> 删除手机中保存的截屏
    def screencap(self):
        os.remove(screen_dir)
        operation_list = [self.adbscreencap,self.adbpull,self.adbrm_screencap]
        for operation in operation_list:
            process = subprocess.Popen(operation, shell=False,stdout=subprocess.PIPE)
            process.wait()
        print("screencap to computer success")

    # 发送邮件（QQ邮箱）
    def sendEmail(self,minute):
        """
        qq邮箱 需要先登录网页版，开启SMTP服务。获取授权码，
        :return:
        """
        now_time = datetime.datetime.now().strftime("%H:%M:%S")
        message = MIMEMultipart('related')
        subject = now_time + '打卡'+'下次打卡随机分钟：'+str(minute)
        message['Subject'] = subject
        message['From'] = Header("打卡日志", 'utf-8')
        message['To'] = receive
        content = MIMEText('<html><body><img src="cid:imageid" alt="imageid"></body></html>', 'html', 'utf-8')
        message.attach(content)
        file = open(screen_dir, "rb")
        img_data = file.read()
        file.close()
        img = MIMEImage(img_data)
        img.add_header('Content-ID', 'imageid')
        message.attach(img)
        
        filename = "log.mp4"
        part = MIMEApplication(open(filename,'rb').read())
        part.add_header('Content-Disposition', 'attachment', filename=filename) 
        message.attach(part)
        
        try:
            server = smtplib.SMTP_SSL(smtp, 465)
            server.login(sender, psw)
            server.sendmail(sender, receive, message.as_string())
            server.quit()
            print("邮件发送成功")
        except smtplib.SMTPException as e:
            print(e)


def sendNoteEmail(to, Subject,content):
    """
    qq邮箱 需要先登录网页版，开启SMTP服务。获取授权码，
    :return:
    """
    message = MIMEMultipart('related')
    message['Subject'] = Subject
    message['From'] = Header("打卡日志", 'utf-8')
    message['To'] = to
    content = MIMEText('<html><body>' + content + '</body></html>', 'html', 'utf-8')
    message.attach(content)

    try:
        server = smtplib.SMTP_SSL(smtp, 465)
        server.login(sender, psw)
        server.sendmail(sender, to, message.as_string())
        server.quit()
        print("邮件发送成功")
    except smtplib.SMTPException as e:
        print(e)
            
# 随机打卡时间段
def random_minute():
    return random.randint(30,50)
    
def random_coord(coord, size):
    scoord = coord.split( )
    scoord[0] = int(scoord[0])
    scoord[1] = int(scoord[1])
    scoord[0] += random.randint(0 - size, size)
    scoord[1] += random.randint(0 - size, size)
    return str(scoord[0]) + ' ' + str(scoord[1])

# 包装循环函数，传入随机打卡时间点
def incode_loop(func,minute):
    """
    包装start_loop任务调度函数，主要是为了传入随机分钟数。保证在不打卡的情况下能保持分钟数不变。
    :param func: star_loop
    :param minute: 随机分钟数
    :return: None
    """
    print("邮件接收地址"+receive)
    # 判断时间当超过上班时间则打下班卡。否则则打上班卡。
    if datetime.datetime.now().hour >=go_hour and datetime.datetime.now().hour <back_hour:
        # 用来分类上班和下班。作为参数传入任务调度
        hourtype = 1
        print("下班将在", str(back_hour), ":", str(minute), "打卡")
    else:
        hourtype = 2
        print("上班将在", str(go_hour), ":", str(minute), "打卡")
    #执行任务调度函数
    func(hourtype,minute)


# 任务调度
def start_loop(hourtype,minute):
    """
    每次循环完成，携带生成的随机分钟数来再次进行循环，当打卡后，再重新生成随机数
    :param hourtype: 设置的上班时间点
    :param minute: 随机生成的分钟数（30-55）
    :return: None
    """
    now_time = datetime.datetime.now()
    now_hour = now_time.hour
    now_minute = now_time.minute
    hourtype = hourtype
    # 上班，不是周末（双休），小时对应，随机分钟对应
    if hourtype == 2 and now_hour == go_hour and now_minute == minute:
        print("hourtype",str(hourtype),"now_hour",str(now_hour),"now_minute",str(now_minute))
        random_time = random_minute()
        if is_weekend():
            dingding(directory).goto_work(random_time)
        scheduler.enter(0,0,incode_loop,(start_loop,random_time,))
        return
    if hourtype == 1 and now_hour == back_hour and now_minute == minute:
        print("hourtype", str(hourtype), "now_hour", str(now_hour),"now_minute",str(now_minute))
        random_time = random_minute()
        if is_weekend():
            dingding(directory).after_work(random_time)
        scheduler.enter(0, 0, incode_loop,(start_loop,random_time,))
        return
    else:
        sys.stdout.flush()
        #print(now_hour,':',now_minute)
        #random_time = random_minute()
        #dingding(directory).goto_work(random_time)
        #os._exit(0)
        scheduler.enter(60,0,start_loop,(hourtype,minute,))
        return

# 是否是周末
def is_weekend():
    """
    :return: if weekend return False else return True
    """
    now_time = datetime.datetime.now().strftime("%w")
    if now_time == "6" or now_time == "0":
        return False
    else:
        return True

def start_video(q):
    os.remove("log.mp4")
    
    process = subprocess.Popen('adb shell rm /sdcard/log.mp4', shell=False,stdout=subprocess.PIPE)
    process.wait()

    process = subprocess.Popen('adb shell screenrecord  --time-limit 60 /sdcard/log.mp4', shell=False,stdout=subprocess.PIPE)
    process.wait()
    
    process = subprocess.Popen('adb pull /sdcard/log.mp4', shell=False,stdout=subprocess.PIPE)
    process.wait()


if __name__ == "__main__":
    process = subprocess.check_output('adb devices')
    if len(process) < 30:
      sendNoteEmail(warnmail, '钉钉adb失败', '打卡adb有问题，赶快查看下原因~')
          
    pids = psutil.pids()
    mypid = os.getppid()
    ddpids = []
    for pid in pids:
        p = psutil.Process(pid)
        # get process name according to pid
        #process_name = p.name()
        try:
          process_cmdline = p.cmdline()
          ppid = p.ppid()
          if 'python' == process_cmdline[0] and 'DingDing.py' == process_cmdline[1]:
            print("Process name is: %s, mypid is: %s pid is: %s" %(process_cmdline, mypid, ppid))
            ddpids.append(pid)
            #os._exit(0)
        except:
          continue
    sys.stdout.flush()
    if len(ddpids) > 1:
      os._exit(0) 

    # ======formal
    scheduler.enter(0,0,incode_loop,(start_loop,random_minute(),))
    scheduler.run()
    # ====test
    #dingding  = dingding(directory)
    #dingding.goto_work(12)
    # ==== weekend
    # print(is_weekend())