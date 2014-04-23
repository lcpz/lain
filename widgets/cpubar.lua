--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2014, Tomasz Bienkowski               
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local newtimer     = require("lain.helpers").newtimer
local first_line   = require("lain.helpers").first_line

local awful        = require("awful")
local beautiful    = require("beautiful")

local cpubar =
{
    colors =
    {
        background = beautiful.bg_normal,
        high       = "#EB8F8F",
        normal     = "#A4CE8A"
    },
    _current_level = 0,
    last_total = 0,
    last_active = 0
}

local function worker(args)
    local args = args or {}
    local timeout = args.timeout or 1
    local settings = args.settings or function() end
    local width = args.width or 63
    local height = args.heigth or 1
    local ticks = args.ticks or false
    local ticks_size = args.ticks_size or 7
    local vertical = args.vertical or false

    cpubar.colors = args.colors or cpubar.colors
    cpubar.bar = awful.widget.progressbar()
    cpubar.bar:set_background_color(cpubar.colors.background)
    cpubar.bar:set_color(cpubar.colors.normal)
    cpubar.bar:set_width(width)
    cpubar.bar:set_height(height)
    cpubar.bar:set_ticks(ticks)
    cpubar.bar:set_ticks_size(ticks_size)
    cpubar.bar:set_vertical(vertical)

    function cpubar.update()
        -- Read the amount of time the CPUs have spent performing
        -- different kinds of work. Read the first line of /proc/stat
        -- which is the sum of all CPUs.
        local times = first_line("/proc/stat")
        local at = 1
        local idle = 0
        local total = 0
        for field in string.gmatch(times, "[%s]+([^%s]+)")
        do
            -- 3 = idle, 4 = ioWait. Essentially, the CPUs have done
            -- nothing during these times.
            if at == 3 or at == 4
            then
                idle = idle + field
            end
            total = total + field
            at = at + 1
        end
        local active = total - idle

        -- Read current data and calculate relative values.
        local dactive = active - cpubar.last_active
        local dtotal = total - cpubar.last_total

        cpubar._current_level = dactive / dtotal
        settings()

        -- Save current data for the next run.
        cpubar.last_active = active
        cpubar.last_total = total

        cpubar.bar:set_value(cpubar._current_level)

        if cpubar._current_level < 0.8 then
            cpubar.bar:set_color(cpubar.colors.normal)
        else
            cpubar.bar:set_color(cpubar.colors.high)
        end

        settings()
    end

    newtimer("cpubar", timeout, cpubar.update)

    return cpubar
end

return setmetatable(cpubar, { __call = function(_, ...) return worker(...) end })
