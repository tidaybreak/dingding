--os.execute("input key event 3")
local sz = require("sz")
local smtp = require("szocket.smtp")
local mime = require("mime2")
local ltn12 = require("ltn12")

require "TSLib"


initLog("test", 0);


local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- encoding
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

function mail(title, body1, attachment)
    from = "<tidaybreak@126.com>" -- 发件人
    --发送列表
    rcpt = {
        "<tidaybreak@163.com>",
    }
	body = {
		preamble = "If your client doesn't understand attachments, \r\n" ..
				   "it will still display the preamble and the epilogue.\r\n" ..
				   "Preamble will probably appear even in a MIME enabled client.",
		-- first part: no headers means plain text, us-ascii.
		-- The mime.eol low-level filter normalizes end-of-line markers.
		[1] = { 
		  headers = {
			["content-type"] = 'text/plain; charset="UTF-8"'
		  },	
		  body = mime.eol(0, body1)
		},
		epilogue = "This might also show up, but after the attachments"
	}
	
  
	for k,v in ipairs(attachment) do  
		name = '=?GB2312?B?tcfCvTIucG5n?='
		name = '=?utf-8?B?55m76ZmGMi5wbmc=?='
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
				to = "tidaybreak@163.com", -- 收件人
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
        toast("邮件发送不成功"..e);
    else
        toast("邮件发送成功");
    end 
    
end

function unlock()
  flag = deviceIsLock();
  if flag ~= 0 then
    unlockDevice();
    mSleep(1000);
  end
end

local sz = require("sz")
local socket = require("szocket") -- 需要用到luasocket库  
local function get_seed()  
    local t = string.format("%f", socket.gettime())
    local st = string.sub(t, string.find(t, "%.") + 1, -1) 
    return tonumber(string.reverse(st))
end  
math.randomseed(get_seed()) 
function randSleep(min, max)
  mSleep(math.random(min,max));
end

local mailBody = "\r\n"
function maillog(con)
  current_time = os.date("%Y-%m-%d %H-%M-%S", os.time());
  mailBody = mailBody.."\r\n["..current_time..'] '..con;
end



	
text = ocrText(50, 450, 660, 780, 1, "");
maillog(text);

--mail("打卡邮件", "邮件发送成功", {[1] = "打卡结果", [2] = "考勤打卡", [3] = "程序启动", [4] = "工作标签"})



 wLog("test", text);



closeLog("test");