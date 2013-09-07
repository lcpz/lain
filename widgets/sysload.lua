
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local markup       = require("lain.util.markup")
local helpers      = require("lain.helpers")

local awful        = require("awful")
local beautiful    = require("beautiful")
local wibox        = require("wibox")

local io           = io
local string       = { format = string.format,
                       match  = string.match }

local setmetatable = setmetatable

-- System load
-- lain.widgets.sysload
local sysload = {}

function worker(args)
    local args = args or {}
    local refresh_timeout = args.refresh_timeout or 5
    local show_all = args.show_all or false
    local header = args.header or " Load "
    local header_color = args.header_color or beautiful.fg_normal or "#FFFFFF"
    local color = args.color or beautiful.fg_focus or header_color
    local app = args.app or "top"

    local mysysload = wibox.widget.textbox()

    local mysysloadupdate = function()
        local f = io.open("/proc/loadavg")
        local ret = f:read("*all")
        f:close()

        if show_all
        then
            local a, b, c = string.match(ret, "([^%s]+) ([^%s]+) ([^%s]+)")
            mysysload:set_text(string.format("%s %s %s", a, b, c))
        else
            local a = string.match(ret, "([^%s]+) ")
            mysysload:set_text(string.format("%s", a))
        end
        mysysload:set_markup(markup(header_color, header) ..
                             markup(color, mysysload._layout.text .. " "))
    end

    local mysysloadtimer = timer({ timeout = refresh_timeout })
    mysysloadtimer:connect_signal("timeout", mysysloadupdate)
    mysysloadtimer:start()
    mysysloadtimer:emit_signal("timeout")

    mysysload:buttons(awful.util.table.join(
        awful.button({}, 0,
            function()
                helpers.run_in_terminal(app)
            end)
    ))

    return mysysload
end

return setmetatable(sysload, { __call = function(_, ...) return worker(...) end })
