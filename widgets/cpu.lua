
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local lines_match  = require("lain.helpers").lines_match
local newtimer     = require("lain.helpers").newtimer
local wibox        = require("wibox")
local math         = { ceil   = math.ceil }
local string       = { format = string.format,
                       gmatch = string.gmatch }
local tostring     = tostring
local setmetatable = setmetatable

-- CPU usage
-- lain.widgets.cpu
local cpu = { core = {} }

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 2
    local settings = args.settings or function() end

    cpu.widget = wibox.widget.textbox()

    function update()
        -- Read the amount of time the CPUs have spent performing
        -- different kinds of work. Read the first line of /proc/stat
        -- which is the sum of all CPUs.
        local times = lines_match("cpu","/proc/stat")

        for index,time in pairs(times) do
            local coreid = index - 1
            local core   = cpu.core[coreid] or
                           { last_active = 0 , last_total = 0, usage = 0 }
            local at     = 1
            local idle   = 0
            local total  = 0

            for field in string.gmatch(time, "[%s]+([^%s]+)") do
                -- 4 = idle, 5 = ioWait. Essentially, the CPUs have done
                -- nothing during these times.
                if at == 4 or at == 5 then
                    idle = idle + field
                end
                total = total + field
                at = at + 1
            end

            local active = total - idle

            if core.last_active ~= active or core.last_total ~= total then
                -- Read current data and calculate relative values.
                local dactive = active - core.last_active
                local dtotal  = total - core.last_total
                local usage   = math.ceil((dactive / dtotal) * 100)

                core.last_active = active
                core.last_total  = total
                core.usage       = usage

                -- Save current data for the next run.
                cpu.core[coreid] = core
            end
        end

        widget = cpu.widget
        cpu_now = cpu.core
        cpu_now.usage = cpu_now[0].usage

        settings()
    end

    newtimer("cpu", timeout, update)

    return setmetatable(cpu, { __index = cpu.widget })
end

return setmetatable(cpu, { __call = function(_, ...) return worker(...) end })
