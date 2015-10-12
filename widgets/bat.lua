
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local helpers      = require("lain.helpers")
local naughty      = require("naughty")
local wibox        = require("wibox")

local math         = { floor  = math.floor }
local string       = { format = string.format }
local tonumber     = tonumber

local setmetatable = setmetatable

-- Battery infos
-- lain.widgets.bat

local function worker(args)
    local bat = {}
    local args = args or {}
    local timeout = args.timeout or 30
    local battery = args.battery or "BAT0"
    local notify = args.notify or "on"
    local settings = args.settings or function() end

    bat.widget = wibox.widget.textbox('')

    bat_notification_low_preset = {
        title = "Battery low",
        text = "Plug the cable!",
        timeout = 15,
        fg = "#202020",
        bg = "#CDCDCD"
    }

    bat_notification_critical_preset = {
        title = "Battery exhausted",
        text = "Shutdown imminent",
        timeout = 15,
        fg = "#000000",
        bg = "#FFFFFF"
    }

    helpers.set_map(battery .. "status", "N/A")
    helpers.set_map(battery .. "perc", "N/A")
    helpers.set_map(battery .. "time", "N/A")
    helpers.set_map(battery .. "watt", "N/A")

    function update()
        bat_now = {
            status = "Not present",
            perc   = "N/A",
            time   = "N/A",
            watt   = "N/A"
        }

        local bstr  = "/sys/class/power_supply/" .. battery

        local present = helpers.first_line(bstr .. "/present")

        if present == "1"
        then
            local rate  = helpers.first_line(bstr .. "/power_now") or
                          helpers.first_line(bstr .. "/current_now")

            local ratev = helpers.first_line(bstr .. "/voltage_now")

            local rem   = helpers.first_line(bstr .. "/energy_now") or
                          helpers.first_line(bstr .. "/charge_now")

            local tot   = helpers.first_line(bstr .. "/energy_full") or
                          helpers.first_line(bstr .. "/charge_full")

            bat_now.status = helpers.first_line(bstr .. "/status") or "N/A"

            rate  = tonumber(rate) or 1
            ratev = tonumber(ratev)
            rem   = tonumber(rem)
            tot   = tonumber(tot)

            local time_rat = 0
            if bat_now.status == "Charging"
            then
                time_rat = (tot - rem) / rate
            elseif bat_now.status == "Discharging"
            then
                time_rat = rem / rate
            end

            local hrs = math.floor(time_rat)
            if hrs < 0 then hrs = 0 elseif hrs > 23 then hrs = 23 end

            local min = math.floor((time_rat - hrs) * 60)
            if min < 0 then min = 0 elseif min > 59 then min = 59 end

            bat_now.time = string.format("%02d:%02d", hrs, min)

            bat_now.perc = helpers.first_line(bstr .. "/capacity")

            if not bat_now.perc then
                local perc = (rem / tot) * 100
                if perc <= 100 then
                    bat_now.perc = string.format("%d", perc)
                elseif perc > 100 then
                    bat_now.perc = "100"
                elseif perc < 0 then
                    bat_now.perc = "0"
                end
            end

            if rate ~= nil and ratev ~= nil then
                bat_now.watt = string.format("%.2fW", (rate * ratev) / 1e12)
            else
                bat_now.watt = "N/A"
            end
        end

        if bat_now.status ~= helpers.get_map(battery .. "status")
           or bat_now.perc ~= helpers.get_map(battery .. "perc")
           or bat_now.time ~= helpers.get_map(battery .. "time")
           or bat_now.watt ~= helpers.get_map(battery .. "watt")
        then
            widget = bat.widget
            settings()

            helpers.set_map(battery .. "status", bat_now.status)
            helpers.set_map(battery .. "perc", bat_now.perc)
            helpers.set_map(battery .. "time", bat_now.time)
            helpers.set_map(battery .. "watt", bat_now.watt)
        end

        -- notifications for low and critical states
        if bat_now.status == "Discharging" and notify == "on" and bat_now.perc ~= nil
        then
            local nperc = tonumber(bat_now.perc) or 100
            if nperc <= 5
            then
                bat.id = naughty.notify({
                    preset = bat_notification_critical_preset,
                    replaces_id = bat.id,
                }).id
            elseif nperc <= 15
            then
                bat.id = naughty.notify({
                    preset = bat_notification_low_preset,
                    replaces_id = bat.id,
                }).id
            end
        end
    end

    helpers.newtimer(battery, timeout, update)

    return bat.widget
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
