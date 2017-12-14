local helpers  = require("lain.helpers")
local wibox    = require("wibox")
local open     = io.open
local tonumber = tonumber

-- wifi link info
-- lain.widget.wifi

local function factory(args)
    local wifi	   = { widget = wibox.widget.textbox() }
    local args	   = args or {}
    local timeout  = args.timeout or 2
    local wififile = args.wififile or "/proc/net/wireless"
    local settings = args.settings or function() end
	
    function wifi.update()
	local f = open(wififile)
	local wcontent
	if f then
	    wcontent = f:read("*all")
	    f:close()
	end

	local pattern = " (%-%d+)%."

	
	wifi_link = wcontent:match(pattern) or "--"
	widget = wifi.widget
	settings()
    end
	
    helpers.newtimer("wifi", timeout, wifi.update)
    
    return wifi

end -- function factory

return factory

