
--[[
                                                           
     Licensed under GNU General Public License v2          
      * (c) 2013,      Luke Bonham                         
      * (c) 2010-2012, Peter Hofmann                       
      * (c) 2010,      Adrian C.      <anrxc@sysphere.org> 
      * (c) 2009,      Lucas de Vries <lucas@glacicle.com> 
                                                           
--]]

local newtimer        = require("lain.helpers").newtimer

local wibox           = require("wibox")

local io              = { lines  = io.lines }
local math            = { floor  = math.floor }
local string          = { format = string.format,
                          gmatch = string.gmatch,
                          len    = string.len }

local setmetatable    = setmetatable

-- Memory usage (ignoring caches)
-- lain.widgets.mem
local mem = {}

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 3
    local settings = args.settings or function() end

    mem.widget = wibox.widget.textbox('')

    function mem.update()
        mem = {}
        for line in io.lines("/proc/meminfo")
        do
            for k, v in string.gmatch(line, "([%a]+):[%s]+([%d]+).+")
            do
                if     k == "MemTotal"  then mem.total = math.floor(v / 1024)
                elseif k == "MemFree"   then mem.free  = math.floor(v / 1024)
                elseif k == "Buffers"   then mem.buf   = math.floor(v / 1024)
                elseif k == "Cached"    then mem.cache = math.floor(v / 1024)
                elseif k == "SwapTotal" then mem.swap  = math.floor(v / 1024)
                elseif k == "SwapFree"  then mem.swapf = math.floor(v / 1024)
                end
            end
        end

        used = mem.total - (mem.free + mem.buf + mem.cache)
        swapused = mem.swap - mem.swapf

        widget = mem.widget
        settings()
    end

    newtimer("mem", timeout, mem.update)

    return mem.widget
end

return setmetatable(mem, { __call = function(_, ...) return worker(...) end })
