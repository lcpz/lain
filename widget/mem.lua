--[[

     Licensed under GNU General Public License v2
      * (c) 2013,      Luca CPZ
      * (c) 2010-2012, Peter Hofmann

--]]
local gmatch, lines, floor = string.gmatch, io.lines, math.floor
local wibox                = require("wibox")
local helpers              = require("lain.helpers")

-- Memory usage (ignoring caches)
-- lain.widget.mem

local function factory(args)
    args           = args or {}

    local mem      = { widget = args.widget or wibox.widget.textbox() }

    mem.settings   = args.settings or function() end
    mem.timeout    = args.timeout or 2

    function mem.update()
        for line in lines("/proc/meminfo") do
            for k, v in gmatch(line, "([%a]+):[%s]+([%d]+).+") do
                if k == "Buffers"      then mem.buf   = floor(v / 1024 + 0.5)
                elseif k == "Cached"       then mem.cache = floor(v / 1024 + 0.5)
                elseif k == "MemFree"      then mem.free  = floor(v / 1024 + 0.5)
                elseif k == "MemTotal"     then mem.total = floor(v / 1024 + 0.5)
                elseif k == "SReclaimable" then mem.srec  = floor(v / 1024 + 0.5)
                elseif k == "SwapFree"     then mem.swapf = floor(v / 1024 + 0.5)
                elseif k == "SwapTotal"    then mem.swap  = floor(v / 1024 + 0.5)
                end
            end
        end

        mem.swapused = mem.swap - mem.swapf
        mem.used = mem.total - mem.free - mem.buf - mem.cache - mem.srec

        mem.perc = math.floor(mem.used / mem.total * 100)

        mem.settings()
    end

    helpers.newtimer("mem", mem.timeout, mem.update)

    return mem
end

return factory
