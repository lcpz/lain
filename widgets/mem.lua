
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local helpers      = require("lain.helpers")
local wibox        = require("wibox")

local io           = { lines  = io.lines }
local math         = { floor  = math.floor }
local string       = { gmatch = string.gmatch }

local setmetatable = setmetatable

-- Memory usage
-- lain.widgets.mem
local mem = {}

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 1
    local settings = args.settings or function() end

    mem.widget = wibox.widget.textbox('')

    helpers.set_map("mem_last_total", 0)
    helpers.set_map("mem_last_free", 0)
    helpers.set_map("mem_last_buf", 0)
    helpers.set_map("mem_last_cache", 0)
    helpers.set_map("mem_last_swap", 0)
    helpers.set_map("mem_last_swapf", 0)

    function update()
        mem_now = {}
        for line in io.lines("/proc/meminfo")
        do
            for k, v in string.gmatch(line, "([%a]+):[%s]+([%d]+).+")
            do
                if     k == "MemTotal"  then mem_now.total = math.floor(v / 1024)
                elseif k == "MemFree"   then mem_now.free  = math.floor(v / 1024)
                elseif k == "Buffers"   then mem_now.buf   = math.floor(v / 1024)
                elseif k == "Cached"    then mem_now.cache = math.floor(v / 1024)
                elseif k == "SwapTotal" then mem_now.swap  = math.floor(v / 1024)
                elseif k == "SwapFree"  then mem_now.swapf = math.floor(v / 1024)
                end
            end
        end

        if mem_now.total ~= helpers.set_map("mem_last_total")
        or mem_now.free  ~= helpers.set_map("mem_last_free")
        or mem_now.buf   ~= helpers.set_map("mem_last_buf")
        or mem_now.cache ~= helpers.set_map("mem_last_cache")
        or mem_now.swap  ~= helpers.set_map("mem_last_swap")
        or mem_now.swapf ~= helpers.set_map("mem_last_swapf")
        then
            mem_now.used = mem_now.total - (mem_now.free + mem_now.buf + mem_now.cache)
            mem_now.swapused = mem_now.swap - mem_now.swapf

            widget = mem.widget
            settings()

            helpers.set_map("mem_last_total", mem_now.total)
            helpers.set_map("mem_last_free", mem_now.free)
            helpers.set_map("mem_last_buf", mem_now.buf)
            helpers.set_map("mem_last_cache", mem_now.cache)
            helpers.set_map("mem_last_swap", mem_now.swap)
            helpers.set_map("mem_last_swapf", mem_now.swapf)
        end
    end

    helpers.newtimer("mem", timeout, update)

    return mem.widget
end

return setmetatable(mem, { __call = function(_, ...) return worker(...) end })
