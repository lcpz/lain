
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local newtimer     = require("lain.helpers").newtimer
local first_line   = require("lain.helpers").first_line

local naughty      = require("naughty")
local wibox        = require("wibox")

local math         = { floor  = math.floor }
local string       = { format = string.format }

local setmetatable = setmetatable

-- Battery infos
-- lain.widgets.bat
local bat = { id = nil }

local function worker(args)
    local args = args or {}
    local timeout = args.timeout or 30
    local battery = args.battery or "BAT0"
    local settings = args.settings or function() end

    bat_now = {
        status = "not present",
        perc   = "N/A",
        time   = "N/A",
        watt   = "N/A"
    }

    widget = wibox.widget.textbox('')

    function update()
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
            bat_now.status = first_line("/sys/class/power_supply/"
                                    .. battery ..
                                   "/status")

            local time_rat = 0
            if bat_now.status == "Charging"
            then
                time_rat = (tot - rem) / rate
            elseif bat_now.status == "Discharging"
            then
                time_rat = rem / rate
            end

            local hrs = math.floor(time_rat)
            local min = (time_rat - hrs) * 60

            bat_now.time = string.format("%02d:%02d", hrs, min)
            bat_now.perc = (rem / tot) * 100
            bat_now.watt = string.format("%.2fW", (rate * ratev) / 1e12)

            -- notifications for low and critical states
            if bat_now.perc <= 5
            then
                bat.id = naughty.notify({
                    text = "shutdown imminent",
                    title = "battery nearly exhausted",
                    position = "top_right",
                    timeout = 15,
                    fg="#000000",
                    bg="#ffffff",
                    ontop = true,
                    replaces_id = bat.id
                }).id
            elseif bat.perc <= 15
            then
                bat.id = naughty.notify({
                    text = "plug the cable",
                    title = "battery low",
                    position = "top_right",
                    timeout = 15,
                    fg="#202020",
                    bg="#cdcdcd",
                    ontop = true,
                    replaces_id = bat.id
                }).id
            end

            bat_now.perc = string.format("%d", bat_now.perc)
        end

        settings()
    end

    newtimer("bat", timeout, update)

    return widget
end

return setmetatable(bat, { __call = function(_, ...) return worker(...) end })
