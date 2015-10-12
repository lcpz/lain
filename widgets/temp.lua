
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
                                                  
--]]

local helpers      = require("lain.helpers")
local wibox        = require("wibox")

local io           = { open = io.open }
local tonumber     = tonumber

local setmetatable = setmetatable

-- coretemp
-- lain.widgets.temp
local temp = {}

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 1
    local tempfile = args.tempfile or "/sys/class/thermal/thermal_zone0/temp"
    local settings = args.settings or function() end

    temp.widget = wibox.widget.textbox('')
    helpers.set_map("temp_last", 0)

    function update()
        local f = io.open(tempfile)
        if f ~= nil
        then
            coretemp_now = tonumber(f:read("*all")) / 1000
            f:close()
        else
            coretemp_now = "N/A"
        end

        if helpers.get_map("temp_last") ~= coretemp_now then
            widget = temp.widget
            settings()
            helpers.set_map("temp_last", coretemp_now)
        end
    end

    helpers.newtimer("coretemp", timeout, update)

    return temp.widget
end

return setmetatable(temp, { __call = function(_, ...) return worker(...) end })
