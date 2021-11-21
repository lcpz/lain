--[[

     Licensed under GNU General Public License v2
      * (c) 2021, nenikitov <https://github.com/nenikitov>

--]]

local helpers              = require("lain.helpers")
local wibox                = require("wibox")
local match, lines, floor  = string.match, io.lines, math.floor

local function factory(args)
    args           = args or {}

    local uptime   = { widget = args.widget or wibox.widget.textbox() }
    local timeout  = args.timeout or 1
    local settings = args.settings or function() end

    function uptime.update()
        uptime_now = {}

        for line in lines("/proc/uptime") do
            local secs = floor(match(line, "^[0-9.]+"))

            uptime_now.total_seconds = secs
            uptime_now.total_minutes = floor(secs / 60)
            uptime_now.total_hours   = floor(uptime_now.minutes / 60)
            uptime_now.total_days    = floor(uptime_now.total_hours / 24)

            uptime_now.seconds = uptime_now.total_seconds % 60
            uptime_now.minutes = uptime_now.total_minutes % 60
            uptime_now.hours   = uptime_now.total_hours   % 24

            widget = uptime.widget
            settings()
        end
    end

    helpers.newtimer("uptime", timeout, uptime.update)

    return uptime
end

return factory
