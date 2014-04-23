--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2014, Tomasz Bienkowski               
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local newtimer     = require("lain.helpers").newtimer

local awful        = require("awful")
local beautiful    = require("beautiful")

local membar =
{
    colors =
    {
        background = beautiful.bg_normal,
        low       = "#EB8F8F",
        normal     = "#A4CE8A"
    },
    _current_level = 0,
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

    membar.colors = args.colors or membar.colors
    membar.bar = awful.widget.progressbar()
    membar.bar:set_background_color(membar.colors.background)
    membar.bar:set_color(membar.colors.normal)
    membar.bar:set_width(width)
    membar.bar:set_height(height)
    membar.bar:set_ticks(ticks)
    membar.bar:set_ticks_size(ticks_size)
    membar.bar:set_vertical(vertical)

    function membar.update()
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

        mem_now.used = mem_now.total - (mem_now.free + mem_now.buf + mem_now.cache)
        mem_now.swapused = mem_now.swap - mem_now.swapf

        membar._current_level = mem_now.used / mem_now.total
        membar.bar:set_value(membar._current_level)

        if membar._current_level < 0.8 then
            membar.bar:set_color(membar.colors.normal)
        else
            membar.bar:set_color(membar.colors.low)
        end

        settings()
    end

    newtimer("membar", timeout, membar.update)

    return membar
end

return setmetatable(membar, { __call = function(_, ...) return worker(...) end })
