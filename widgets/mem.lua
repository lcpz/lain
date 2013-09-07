
--[[
                                                           
     Licensed under GNU General Public License v2          
      * (c) 2013,      Luke Bonham                         
      * (c) 2010-2012, Peter Hofmann                       
      * (c) 2010,      Adrian C.      <anrxc@sysphere.org> 
      * (c) 2009,      Lucas de Vries <lucas@glacicle.com> 
                                                           
--]]

local markup          = require("lain.util.markup")
local run_in_terminal = require("lain.helpers").run_in_terminal

local beautiful       = require("beautiful")
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

function worker(args)
    local args = args or {}
    local refresh_timeout = args.refresh_timeout or 10
    local show_swap = args.show_swap or false
    local show_total = args.show_total or false
    local header = args.header or " Mem "
    local header_color = args.header or beautiful.fg_normal or "#FFFFFF"
    local color = args.color or beautiful.fg_focus or "#FFFFFF"
    local footer = args.footer or "MB"

    local widg = wibox.widget.textbox()

    local upd = function()
        local mem = {}
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

        if show_total
        then
            local fmt = "%" .. string.len(mem.total) .. ".0f/%.0f"
            widg:set_markup(markup(header_color, header) ..
                            markup(color, string.format(fmt, used, mem.total) .. footer .. " "))
        else
            widg:set_markup(markup(header_color, header) ..
                            markup(color, used .. footer .. " "))
        end

        if show_swap
        then
            widg:set_markup(widg._layout.text .. ' ('
                            .. string.format('%.0f '.. footer, swapused)
                            .. ') ')
        end
    end

    local tmr = timer({ timeout = refresh_timeout })
    tmr:connect_signal("timeout", upd)
    tmr:start()
    tmr:emit_signal("timeout")

    return widg
end

return setmetatable(mem, { __call = function(_, ...) return worker(...) end })
