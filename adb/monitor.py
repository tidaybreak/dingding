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
sender = config.get("email","sender")
psw = config.get("email","psw")
smtp = config.get("email","smtp")
warnmail = config.get("email","warnmail")
ip = config.get("email","ip")


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

if __name__ == "__main__":
    process = subprocess.check_output('adb devices')
    print(process)
    if len(process) < 30 or ('unauthorized' in str(process)) or ('offline' in str(process)):
      sendNoteEmail(warnmail, '钉钉adb失败', str(process))
      subprocess.check_output('adb kill-server')
      subprocess.check_output('adb start-server')

    backinfo =  os.system('ping -c 1 -w 1 %s'%ip)
    if backinfo:
      print('no')
      sendNoteEmail(warnmail, '钉钉ping不通', '网络ping不通，赶快查看下原因~')
      subprocess.check_output('adb reboot')
    else:
      iplist = list()
      iplist.append(ip)
      print(iplist)
      