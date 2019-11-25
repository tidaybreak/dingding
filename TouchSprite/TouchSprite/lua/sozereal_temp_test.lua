_G.nLog=_G.nLog or(function()end)pcall(function()local ip _G.setNLogIP=function(_ip)ip=_ip end _G.nLog=(function(_ip,p)ip=_ip local nl=_G.nLog local _p local h=type(http)=='table'and http if h then _p=h.post else pcall(require,'sz')local ht=require'szocket.http' local l=require'ltn12' _p=function(u,tm,_,m)u=tostring(u)tm=tonumber(tm)or 1 m=tostring(m)local rb={}local ne,r,c,h=pcall(ht.request,{url=u,method='POST',headers={['Content-Type']='application/x-www-form-urlencoded',['Content-Length']=#m},source=l.source.string(m),sink=l.sink.table(rb)})if ne then return c,h,table.concat(rb)else return 0,{},'' end end end return(function(m)m=tostring(m):gsub('%[DATE%]',os.date('[%Y-%m-%d %H:%M:%S]')):gsub('%[LINE%]','['..tostring(debug.getinfo(2).currentline)..']')local st=_p('http://'..ip..':'..tostring(p)..'/nLog',1,'{}',m)if(200==st)then return true end _G.nLog=nl return false end)end)('192.168.1.222',55516)end) 
if not multiColor then
	function multiColor(arr,s)
		local fl,abs = math.floor,math.abs
		s = fl(0xff*(100-s)*0.01)
		keepScreen(true)
		for var = 1, #arr do
			local lr,lg,lb = getColorRGB(arr[var][1],arr[var][2])
			local r = fl(arr[var][3]/0x10000)
			local g = fl(arr[var][3]%0x10000/0x100)
			local b = fl(arr[var][3]%0x100)
			if abs(lr-r) > s or abs(lg-g) > s or abs(lb-b) > s then
				keepScreen(false)
				return false
			end
		end
		keepScreen(false)
		return true
	end
end 
 
						if multiColor({
	{   64,  982, 0x3296fa},
	{   91,  987, 0xffffff},
	{  120,  981, 0x3296fa},
	{   90,  496, 0x3296fa},
}, 80) then
							nLog("相似度80以上")
						else
							nLog("相似度80以下")
						end 
						