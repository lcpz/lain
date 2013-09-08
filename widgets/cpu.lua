
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local markup       = require("lain.util.markup")
local first_line   = require("lain.helpers").first_line

local beautiful    = require("beautiful")
local wibox        = require("wibox")

local math         = { ceil   = math.ceil }
local string       = { format = string.format,
                       gmatch = string.gmatch }

local setmetatable = setmetatable

-- CPU usage
-- lain.widgets.cpu
local cpu = {
    last_total = 0,
    last_active = 0
}

function worker(args)
    local args = args or {}
    local refresh_timeout = args.refresh_timeout or 5
    local header = args.header or " Cpu "
    local header_color = args.header or beautiful.fg_normal or "#FFFFFF"
    local color = args.color or beautiful.fg_focus or "#FFFFFF"
    local footer = args.footer or "% "

    local w = wibox.widget.textbox()

    local cpuusageupdate = function()
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
        local dactive = active - cpu.last_active
        local dtotal = total - cpu.last_total
        local dta = math.ceil((dactive / dtotal) * 100)

        w:set_markup(markup(header_color, header) .. markup(color, dta .. footer))

        -- Save current data for the next run.
        cpu.last_active = active
        cpu.last_total = total
    end

    local cpuusagetimer = timer({ timeout = refresh_timeout })
    cpuusagetimer:connect_signal("timeout", cpuusageupdate)
    cpuusagetimer:start()
    cpuusagetimer:emit_signal("timeout")

    return w
end

return setmetatable(cpu, { __call = function(_, ...) return worker(...) end })
