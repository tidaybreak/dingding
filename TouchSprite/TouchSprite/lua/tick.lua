--os.execute("input key event 3")


local sz = require("sz")
local http = require("szocket.http")

ip = getNetworkIP();
local res, code = http.request("http://www.tiham.com/shell/ddtick.php?update=1&ip="..ip);
if code == 200 then
    --dialog(res,0);
end