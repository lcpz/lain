
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
                                                  
--]]

local markup       = require("lain.util.markup")

local beautiful    = require("beautiful")
local wibox        = require("wibox")

local io           = io
local tonumber     = tonumber

local setmetatable = setmetatable

-- coretemp
-- lain.widgets.temp
local temp = {}

function worker(args)
    local args = args or {}
    local refresh_timeout = args.refresh_timeout or 5
    local header = args.header or " Temp "
    local header_color = args.header_color or beautiful.fg_normal or "#FFFFFF"
    local color = args.color or beautiful.fg_focus or header_color
    local footer = args.footer or "C "

    local mytemp = wibox.widget.textbox()

    local mytempupdate = function()
        local f = io.open("/sys/class/thermal/thermal_zone0/temp")
        local ret = f:read("*all")
        f:close()

        ret = tonumber(ret) / 1000

        mytemp:set_markup(markup(header_color, header) ..
                          markup(color, ret .. footer))
    end

    local mytemptimer = timer({ timeout = refresh_timeout })
    mytemptimer:connect_signal("timeout", mytempupdate)
    mytemptimer:start()
    mytemptimer:emit_signal("timeout")

    return mytemp
end

return setmetatable(temp, { __call = function(_, ...) return worker(...) end })
