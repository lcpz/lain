
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local markup       = require("lain.util.markup")
local first_line   = require("lain.helpers").first_line

local beautiful    = require("beautiful")
local naughty      = require("naughty")
local wibox        = require("wibox")

local math         = { floor  = math.floor }
local string       = { format = string.format }

local setmetatable = setmetatable

-- Battery infos
-- lain.widgets.bat
local bat = {
    status = "not present",
    perc   = "N/A",
    time   = "N/A",
}

function worker(args)
    local args = args or {}
    local battery = args.battery or "BAT0"
    local show_all = args.show_all or false
    local refresh_timeout = args.refresh_timeout or 30
    local header = args.header or " Bat "
    local header_color = args.header_color or beautiful.fg_normal or "#FFFFFF"
    local color = args.color or beautiful.fg_focus or "#FFFFFF"
    local shadow = args.shadow or false

    local mybattery = wibox.widget.textbox()

    local mybatteryupdate = function()
        local present = first_line("/sys/class/power_supply/"
                                   .. battery
                                   .. "/present")

        if present == "1"
        then
            local rate = first_line("/sys/class/power_supply/"
                                    .. battery ..
                                    "/power_now")
            local ratev = first_line("/sys/class/power_supply/"
                                    .. battery ..
                                     "/voltage_now")
            local rem = first_line("/sys/class/power_supply/"
                                    .. battery ..
                                   "/energy_now")
            local tot = first_line("/sys/class/power_supply/"
                                    .. battery ..
                                   "/energy_full")
            bat.status = first_line("/sys/class/power_supply/"
                                    .. battery ..
                                   "/status")

            local time_rat = 0
            if bat.status == "Charging"
            then
                status = "(+)"
                time_rat = (tot - rem) / rate
            elseif bat.status == "Discharging"
            then
                status = "(-)"
                time_rat = rem / rate
            else
                status = "(.)"
            end

            local hrs = math.floor(time_rat)
            local min = (time_rat - hrs) * 60
            bat.time = string.format("%02d:%02d", hrs, min)

            local amount = (rem / tot) * 100

            if shadow
            then
                bat.perc = string.format("%d", amount)
            else
                bat.perc = string.format("%d%%", amount)
            end

            local watt = string.format("%.2fW", (rate * ratev) / 1e12)

            if show_all
            then
                text = watt .. " " .. bat.perc .. " " .. bat.time .. " " .. bat.status
            else
                text = bat.perc
            end

            -- notifications for low and critical states
            if amount <= 5
            then
                naughty.notify{
                    text = "shutdown imminent",
                    title = "battery nearly exhausted",
                    position = "top_right",
                    timeout = 15,
                    fg="#000000",
                    bg="#ffffff",
                    ontop = true
                }
            elseif amount <= 15
            then
                old_id = naughty.notify{
                    text = "plug the cable",
                    title = "battery low",
                    position = "top_right",
                    timeout = 5,
                    fg="#202020",
                    bg="#cdcdcd",
                    ontop = true
                }
            end
        else
            text = "none"
        end

        if shadow
        then
            mybattery:set_text('')
        else
            mybattery:set_markup(markup(header_color, header)
                                 .. markup(color, text) .. " ")
        end
    end

    local mybatterytimer = timer({ timeout = refresh_timeout })
    mybatterytimer:connect_signal("timeout", mybatteryupdate)
    mybatterytimer:start()
    mybatterytimer:emit_signal("timeout")

    bat.widget = mybattery

    return setmetatable(bat, { __index = bat.widget })
end

return setmetatable(bat, { __call = function(_, ...) return worker(...) end })
