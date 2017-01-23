
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local newtimer     = require("lain.helpers").newtimer
local wibox        = require("wibox")
local gmatch       = string.gmatch
local lines        = io.lines
local math         = { ceil = math.ceil, floor = math.floor }
local setmetatable = setmetatable

-- Memory usage (ignoring caches)
-- lain.widgets.mem
local mem = {}

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 2
    local settings = args.settings or function() end

    mem.widget = wibox.widget.textbox()

    function update()
        mem_now = {}
        for line in lines("/proc/meminfo") do
            for k, v in gmatch(line, "([%a]+):[%s]+([%d]+).+") do
                if     k == "MemTotal"     then mem_now.total = math.ceil(v / 1024)
                elseif k == "MemFree"      then mem_now.free  = math.ceil(v / 1024)
                elseif k == "Buffers"      then mem_now.buf   = math.ceil(v / 1024)
                elseif k == "Cached"       then mem_now.cache = math.ceil(v / 1024)
                elseif k == "SwapTotal"    then mem_now.swap  = math.ceil(v / 1024)
                elseif k == "SwapFree"     then mem_now.swapf = math.ceil(v / 1024)
                elseif k == "SReclaimable" then mem_now.srec  = math.ceil(v / 1024)
                end
            end
        end

        mem_now.used = mem_now.total - mem_now.free - mem_now.buf - mem_now.cache - mem_now.srec
        mem_now.swapused = mem_now.swap - mem_now.swapf
        mem_now.perc = math.floor(mem_now.used / mem_now.total * 100)

        widget = mem.widget
        settings()
    end

    newtimer("mem", timeout, update)

    return mem.widget
end

return setmetatable(mem, { __call = function(_, ...) return worker(...) end })
