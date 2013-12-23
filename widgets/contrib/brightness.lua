
--[[
                                                   
     Licensed under GNU General Public License v2  
      * (c) 2013, yawnt <yawn.localhost@gmail.com> 
                                                   
--]]

local newtimer        = require("lain.helpers").newtimer

local wibox           = require("wibox")
local io              = { popen  = io.popen }
local string          = { match  = string.match }

local setmetatable    = setmetatable

-- Brightness level
-- lain.widgets.contrib.brightness
local brightness = {}

local function worker(args)
    local args      = args or {}
    local backlight = args.backlight or "acpi_video0"
    local timeout   = args.timeout or 5
    local settings  = args.settings or function() end

    brightness.widget = wibox.widget.textbox('')

    function brightness.update()
        local f = assert(io.popen('cat /sys/class/backlight/' .. backlight .. "/brightness"))
        brightness_now = f:read("*a")
        f:close()

        widget = brightness.widget
        settings()
    end

    newtimer("brightness", timeout, brightness.update)

    return setmetatable(brightness, { __index = brightness.widget })
end

return setmetatable(brightness, { __call = function(_, ...) return worker(...) end })
