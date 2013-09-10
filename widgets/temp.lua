
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
                                                  
--]]

local newtimer     = require("lain.helpers").newtimer

local wibox        = require("wibox")

local io           = io
local tonumber     = tonumber

local setmetatable = setmetatable

-- coretemp
-- lain.widgets.temp
local temp = {}

function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 5
    local settings = args.settings or function() end

    widget = wibox.widget.textbox('')

    function update()
        local f = io.open("/sys/class/thermal/thermal_zone0/temp")
        coretemp_now = tonumber(f:read("*all")) / 1000
        f:close()
        settings()
    end

    newtimer("coretemp", timeout, update)

    return widget
end

return setmetatable(temp, { __call = function(_, ...) return worker(...) end })
