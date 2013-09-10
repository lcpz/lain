
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local newtimer     = require("lain.helpers").newtimer

local wibox        = require("wibox")

local io           = io
local string       = { format = string.format,
                       match  = string.match }

local setmetatable = setmetatable

-- System load
-- lain.widgets.sysload
local sysload = {}

function worker(args)
    local args = args or {}
    local timeout = args.timeout or 5
    local settings = args.settings or function() end

    widget = wibox.widget.textbox('')

    function update()
        local f = io.open("/proc/loadavg")
        local ret = f:read("*all")
        f:close()
        
        a, b, c = string.match(ret, "([^%s]+) ([^%s]+) ([^%s]+)")

        settings()
    end

    newtimer("sysload", timeout, update)

    return widget
end

return setmetatable(sysload, { __call = function(_, ...) return worker(...) end })
