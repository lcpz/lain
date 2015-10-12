
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local helpers      = require("lain.helpers")
local wibox        = require("wibox")

local io           = { open = io.open }
local string       = { match  = string.match }

local setmetatable = setmetatable

-- System load
-- lain.widgets.sysload
local sysload = {}

local function worker(args)
    local args = args or {}
    local timeout = args.timeout or 1
    local settings = args.settings or function() end

    sysload.widget = wibox.widget.textbox('')
    helpers.set_map("load_1", 0)
    helpers.set_map("load_5", 0)
    helpers.set_map("load_15", 0)

    function update()
        local f = io.open("/proc/loadavg")
        local ret = f:read("*all")
        f:close()

        load_1, load_5, load_15 = string.match(ret, "([^%s]+) ([^%s]+) ([^%s]+)")

        if load_1 ~= helpers.get_map("load_1")
           or load_5 ~= helpers.get_map("load_5")
           or load_15 ~= helpers.get_map("load_15")
        then
            widget = sysload.widget
            settings()

            helpers.set_map("load_1", load_1)
            helpers.set_map("load_5", load_5)
            helpers.set_map("load_15", load_15)
        end
    end

    helpers.newtimer("sysload", timeout, update)

    return sysload.widget
end

return setmetatable(sysload, { __call = function(_, ...) return worker(...) end })
