local sz = require("sz")
local smtp = require("szocket.smtp")
local mime = require("mime2")
require "TSLib"

initLog("test", 0);

--随机数
local sz = require("sz")
local socket = require("szocket") -- 需要用到luasocket库  
local function get_seed()  
    local t = string.format("%f", socket.gettime())
    local st = string.sub(t, string.find(t, "%.") + 1, -1) 
    return tonumber(string.reverse(st))
end  
math.randomseed(get_seed()) 
function randSleep(min, offset)
  mSleep(min + math.random(0,offset));
end


-- encoding
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function base64enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end


local mailBody = ""
function maillog(con)
  toast(con); 
  current_time = os.date("%Y-%m-%d %H-%M-%S", os.time());
  mailBody = mailBody.."\r\n<"..current_time..'> '..con;
  wLog("test", con);
end

function mail(title, body, attachment)
	--send_mail("1083041225@qq.com", title, body, attachment)
	--mSleep(1000);
	send_mail("tidaybreak@126.com", title, body, attachment)
end

function send_mail(to, title, body1, attachment)
    from = "<tidaybreak@126.com>" -- 发件人
    --发送列表
    rcpt = {
        '<'..to..'>',
    }

	body = {
		preamble = "If your client doesn't understand attachments, \r\n" ..
				   "it will still display the preamble and the epilogue.\r\n" ..
				   "Preamble will probably appear even in a MIME enabled client.",
		-- first part: no headers means plain text, us-ascii.
		-- The mime.eol low-level filter normalizes end-of-line markers.
		[1] = { 
		  headers = {
			["content-type"] = 'text/plain; charset="utf-8"'
		  },	
		  body = mime.eol(0, body1)
		},
		epilogue = "This might also show up, but after the attachments"
	}
  
	for k,v in ipairs(attachment) do  
		name = '=?utf-8?B?'..base64enc(v..'.png')..'?='
		body[k+1] = { 
		  headers = {
			["content-type"] = 'image/png; name="'..name..'"; ',
			["content-disposition"] = 'attachment; filename="'..name..'";',
			["content-description"] = 'a beautiful image',
			["content-transfer-encoding"] = "BASE64"
		  },
		  body = ltn12.source.chain(
			ltn12.source.file(io.open("/sdcard/TouchSprite/res/"..v..".png", "rb")),
			ltn12.filter.chain(
			  mime.encode("base64"),
			  mime.wrap()
			)
		  )
		}
	end 	

	mesgt = {
	  headers = {
				to = to, -- 收件人
				subject = title
	  },
	  body = body,
		epilogue = "This might also show up, but after the attachments"
	}
	
	--mesgt['headers']['content-type'] = 'text/plain; charset="utf-8"'
    r, e = smtp.send{
        server = "smtp.126.com", --smtp服务器地址
        user = "tidaybreak@126.com",--smtp验证用户名
        password = "Ti2751231",     --smtp验证密码  
        from = from,
        rcpt = rcpt,
        source = smtp.message(mesgt)
    }
    if not r then
        wLog("test","邮件发送不成功"..e);
    else
        wLog("test","邮件发送成功");
    end 
    
end

function click(x, y)
    touchDown(x, y)
    mSleep(30)
    touchUp(x, y)
end

function notify()
  for var = 1,3 do
    vibrator();
    mSleep(500);
  end
end

function shake()
  types = getDeviceType();
  if types ~= 3 and types ~= 4 then
    shakeDevice(0,0,-3,3000);
    mSleep(3000);
  end
end

function unlock()
  flag = deviceIsLock();
  if flag ~= 0 then
    unlockDevice();
    mSleep(1000);
  end
end


function in_array(value, tbl)
  for k,v in ipairs(tbl) do
    if v == value then
      return true;
    end
  end
  return false;
end

local t = os.date("%Y-%m-%d", os.time())
local nowork = {"2019-04-05", "2019-05-01", "2019-06-07", "2019-09-13", "2019-10-01", "2019-10-02", "2019-10-03", "2019-10-04", "2019-10-07"}
local work_week = {"2019-09-29", "2019-10-12"}
local week = os.date("%A")

if in_array(t, nowork) then
  os.exit()
end

if (week == "Saturday" or week == "Sunday") and in_array(t, work_week) == false then
  os.exit()
end

shake();
unlock();


for var = 1,1 do
  w,h = getScreenSize();
  setAutoLockTime(300*1000)
    
  -- 启动准备
  maillog("启动钉钉,开始打卡!");
  closeApp("com.alibaba.android.rimet");
  randSleep(2000, 1000)
  runApp("com.alibaba.android.rimet") 
  randSleep(18000, 3000);

  -- 这步做完取色才生效 不知道为什么
  setScreenScale(true, 720, 1280);
  randSleep(1000, 1000);
  setScreenScale(false)
 
  
  -- 是否要需要登陆
  snapshot("程序启动.png", 0, 0, w-1, h-1); 
  if multiColor({{250,609,0x030401}}) == true then  --全部坐标点和颜色一致时返回 true，== true 可省略不写
       -- 登陆
        maillog("需要登陆");
        click(250,609);
        randSleep(1000, 1000);
        inputText("wzt19860801"); -- 输入密码
        randSleep(1000, 2000);
        click(350,720);		  -- 点登陆
        randSleep(8000, 3000);
  else
		click(180,1100);	-- 更新版本后要点登陆
		maillog("不需要登陆");
  end
  
  --有更新时操作
  text = ocrText(50, 450, 660, 780, 1, "");
  if text == nil then
	  text = ""
  elseif string.find(text, "暂不更新", 1) ~= nil then
	  click(454,750);
	  mail("需要更新钉钉", mailBody, {[1] = "程序启动"})
	  randSleep(2000, 1000);
  else
	  text = ""
  end 
    
  --点击"工作"
  setScreenScale(true, 720, 1280);
  randSleep(2000, 1000);
  click(360,1100);
  setScreenScale(false)
  randSleep(8000, 3000)
  
  --下拉
  touchDown(360, 550);    --在坐标 (150, 550)按下
  mSleep(30);
  touchMove(360, 500);    --移动到坐标 (150, 600)，注意一次滑动的坐标间隔不要太大，不宜超过50像素
  mSleep(30);
  touchUp(360, 500);  --在坐标 (150, 600) 抬起
  mSleep(2000);
  
  touchDown(360, 550);    --在坐标 (150, 550)按下
  mSleep(30);
  touchMove(360, 500);    --移动到坐标 (150, 600)，注意一次滑动的坐标间隔不要太大，不宜超过50像素
  mSleep(30);
  touchUp(360, 500);  --在坐标 (150, 600) 抬起
  mSleep(2000);
  
  touchDown(360, 550);    --在坐标 (150, 550)按下
  mSleep(30);
  touchMove(360, 500);    --移动到坐标 (150, 600)，注意一次滑动的坐标间隔不要太大，不宜超过50像素
  mSleep(30);
  touchUp(360, 500);  --在坐标 (150, 600) 抬起
  mSleep(2000);  
  
  touchDown(360, 550);    --在坐标 (150, 550)按下
  mSleep(30);
  touchMove(360, 500);    --移动到坐标 (150, 600)，注意一次滑动的坐标间隔不要太大，不宜超过50像素
  mSleep(30);
  touchUp(360, 500);  --在坐标 (150, 600) 抬起
  mSleep(3000);
  
  -- 根据像素模糊查找考勤按钮
  snapshot("工作标签.png", 0, 0, w-1, h-1); 
  --x,y = findMultiColorInRegionFuzzy( 0x3296fa, "27|5|0xffffff,56|-1|0x3296fa", 90, 0, 0, 719, 1279)
  x,y = findMultiColorInRegionFuzzy( 0x3296fa, "-3|3|0xffffff,5|1|0xffffff,-1|10|0x3296fa", 90, 0, 0, 719, 1279)
  --x,y = findMultiColorInRegionFuzzy( 0x4baaed, "0|25|0x4daae8,0|34|0xf2f9ff,-1|42|0x4aaced,0|64|0xfefcfe,0|79|0x4da9ea", 90, 0, 0, 719, 1279)
  if x ~= -1 and y ~= -1 then
      maillog("找到考勤按钮 x:"..x.." y:"..y);
      click(x,y);
  else
	  --click(90, 1000);	
      maillog("找不到考勤按钮");
	  mail("钉钉打卡失败", mailBody, {[1] = "程序启动", [2] = "工作标签"})
	  maillog("结束打卡1!\r\n");
	  closeLog("test");
	  mSleep(2000)
	  os.execute("reboot");
  end
  randSleep(25000, 5000);
  
  
  -- 处理上下班状态
  reboot = true
  isClick = false
  snapshot("考勤打卡.png", 0, 0, w-1, h-1);  
  curr_hour = os.date("%H", os.time());
  curr_mins = os.date("%M", os.time())
  curr_time = tonumber(curr_hour..'.'..curr_mins);
  if curr_time <= 8.30 and curr_time > 7.0 then
	  text = ocrText(0, 340, 719, 700, 1, "");
	  if text == nil then
		  maillog("取不到文字,可能没网络,重启再试!");
		  mail("钉钉上班打卡失败", mailBody, {[1] = "考勤打卡"})		 
	  elseif string.find(text, "打卡时间", 1) ~= nil then
		  maillog("已经打过上班卡");
		  reboot = false
	  elseif string.find(text, "上班打卡", 1) ~= nil then
		  maillog("开始上班打卡");
		  click(360,550);
		  isClick = true	
	  elseif string.find(text, "勤打卡", 1) ~= nil then
		  reboot = false
		  maillog("外勤打卡状态!");		  
	  else
		  maillog("上班打卡状态异常,重启再试!");
		  mail("钉钉上班打卡失败", mailBody, {[1] = "考勤打卡"})
	  end 
	  randSleep(2000, 3000);
  elseif curr_time >= 17.30 then
	  text = ocrText(0, 700, 719, 1000, 1, "");
	  if text == nil then
		  maillog("取不到文字,可能没网络,重启再试!");
		  mail("钉钉上班打卡失败", mailBody, {[1] = "考勤打卡"})	  
	  elseif string.find(text, "打卡时间", 1) ~= nil or string.find(text, "更新打卡", 1) ~= nil then
		  maillog("已经打过下班卡");
		  reboot = false
	  elseif string.find(text, "下班打卡", 1) ~= nil then
		  maillog("开始下班打卡");
		  click(360,900);
		  isClick = true
	  elseif string.find(text, "勤打卡", 1) ~= nil then
		  reboot = false
		  maillog("外勤打卡状态!");		  
	  else
		  maillog("下班打卡状态异常,重启再试!");
		  mail("钉钉下班打卡失败", mailBody, {[1] = "考勤打卡"})
	  end
	  randSleep(2000, 3000);
  else
	  maillog("非打卡时间");
	  reboot = false
  end

  -- 是否打成功 
  snapshot("打卡结果.png", 0, 0, w-1, h-1); 
  if isClick == true then
	  text = ocrText(87, 320, 620, 1023, 1, "");
	  if text ~= nil and (string.find(text, "打卡成功", 1) ~= nil or string.find(text, "我知道了", 1)) then
			maillog("点打卡了有成功提示");
			reboot = false		
	  else
		  -- 点右上角x
		  click(610, 337);  --点关闭
		  randSleep(1000, 2000);
		  if curr_time <= 8.30 and curr_time > 7.0 then
			  text = ocrText(0, 340, 719, 700, 1, "");
			  if text ~= nil and string.find(text, "打卡时间", 1) ~= nil then
				  reboot = false	  
			  else
				  maillog("点完打卡没有成功,重启再试!");
			  end 
		  elseif curr_time >= 17.30 then
			  text = ocrText(0, 700, 719, 1000, 1, "");
			  if text ~= nil and (string.find(text, "打卡时间", 1) ~= nil or string.find(text, "更新打卡", 1) ~= nil) then
				  reboot = false	  
			  else
				  maillog("点完打卡没有成功,重启再试!");
			  end
		  else
			  reboot = false
		  end
	  end
  end
 
 
  -- 结果处理
  setAutoLockTime(120*1000)
  if text == nil then
	maillog("ocr内容:");
  else
	maillog("ocr内容:"..text);
  end
  send_mail("tidaybreak@126.com", "钉钉打卡通知", mailBody, {[1] = "打卡结果", [2] = "考勤打卡", [3] = "程序启动", [4] = "工作标签"})
  maillog("结束打卡!\r\n");
  if reboot == true then
	closeLog("test");
	os.execute("reboot");
  end
  --closeApp("com.touchsprite.android");  --新版本触动不关闭界面会黑屏卡死
  lockDevice();
  

 

end

closeLog("test");
