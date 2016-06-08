
--[[
												                        
	 Licensed under GNU General Public License v2 
	  * (c) 2013,      Luke Bonham                
	  * (c) 2010-2012, Peter Hofmann              
												                        
--]]

local newtimer     = require("lain.helpers").newtimer
local first_line   = require("lain.helpers").first_line

local naughty      = require("naughty")
local wibox        = require("wibox")

local math         = { floor  = math.floor, min = math.min }
local string       = { format = string.format }
local tonumber     = tonumber

local setmetatable = setmetatable

-- Battery infos
-- lain.widgets.bat

local function worker(args)
    local bat       = {}
    local args      = args or {}
    local timeout   = args.timeout or 30
    local batteries = args.batteries or (args.battery and {args.battery}) or {"BAT0"}
    local ac        = args.ac or "AC0"
    local notify    = args.notify or "on"
    local settings  = args.settings or function() end

    bat.widget = wibox.widget.textbox('')

    bat_notification_low_preset = {
        title   = "Battery low",
        text    = "Plug the cable!",
        timeout = 15,
        fg      = "#202020",
        bg      = "#CDCDCD"
    }

    bat_notification_critical_preset = {
        title   = "Battery exhausted",
        text    = "Shutdown imminent",
        timeout = 15,
        fg      = "#000000",
        bg      = "#FFFFFF"
    }

    bat_now = {
        status    = "Not present",
        ac_status = "N/A",
        perc      = "N/A",
        time      = "N/A",
        watt      = "N/A"
    }

    bat_now.n_status = {}
    for i = 1, #batteries do
        bat_now.n_status[i] = "Not present"
    end

    function update()
        local sum_rate_current = 0
        local sum_rate_voltage = 0
        local sum_rate_power = 0
        local sum_energy_now = 0
        local sum_energy_full = 0
        local sum_energy_percentage = 0

        for i, battery in ipairs(batteries) do
            local bstr    = "/sys/class/power_supply/" .. battery
            local present = first_line(bstr .. "/present")

            if present == "1"
            then
                -- current_now(I)[uA], voltage_now(U)[uV], power_now(P)[uW]
                local rate_current      = tonumber(first_line(bstr .. "/current_now"))
                local rate_voltage      = tonumber(first_line(bstr .. "/voltage_now"))
                local rate_power        = tonumber(first_line(bstr .. "/power_now"))

                -- energy_now(P)[uWh], charge_now(I)[uAh]
                local energy_now        = tonumber(first_line(bstr .. "/energy_now") or
                                          first_line(bstr .. "/charge_now"))

                -- energy_full(P)[uWh], charge_full(I)[uAh]
                local energy_full       = tonumber(first_line(bstr .. "/energy_full") or
                                          first_line(bstr .. "/charge_full"))

                local energy_percentage = tonumber(first_line(bstr .. "/capacity")) or
                                          math.floor((energy_now / energy_full) * 100)

                if bat_now.n_status[i] ~= "Charging" and bat_now.n_status[i] ~= "Discharging"
                then
                    bat_now.n_status[i] = first_line(bstr .. "/status") or "N/A"
                end

                sum_rate_current      = sum_rate_current + (rate_current or 0)
                sum_rate_voltage      = sum_rate_voltage + rate_voltage
                sum_rate_power        = sum_rate_power + (rate_power or ((rate_voltage * rate_current) / 1e6))
                sum_energy_now        = sum_energy_now + energy_now
                sum_energy_full       = sum_energy_full + energy_full
                sum_energy_percentage = sum_energy_percentage + energy_percentage
            end
        end

        bat_now.status = bat_now.n_status[1]
        bat_now.ac_status = first_line(string.format("/sys/class/power_supply/%s/online", ac)) or "N/A"

        -- update {perc,time,watt} iff rate > 0 and battery not full
        if (sum_rate_current > 0 or sum_rate_power > 0) and not (bat_now.status == "Full")
        then
            local rate_time = 0

            if bat_now.status == "Charging" then
                rate_time = (sum_energy_full - sum_energy_now) / (sum_rate_power or sum_rate_current)
            elseif bat_now.status == "Discharging" then
                rate_time = sum_energy_now / (sum_rate_power or sum_rate_current)
            end

            local hours   = math.floor(rate_time)
            local minutes = math.floor((rate_time - hours) * 60)
            local watt    = sum_rate_power / 1e6

            bat_now.perc  = string.format("%d", math.min(100, sum_energy_percentage / #batteries))
            bat_now.time  = string.format("%02d:%02d", hours, minutes)
            bat_now.watt  = string.format("%.2fW", watt)
        end

        widget = bat.widget
        settings()

        -- notifications for low and critical states
        if notify == "on" and bat_now.perc and bat_now.status == "Discharging" then
            local nperc = tonumber(bat_now.perc) or 100
            if nperc <= 5 then
                bat.id = naughty.notify({
                    preset = bat_notification_critical_preset,
                    replaces_id = bat.id,
                }).id
            elseif nperc <= 15 then
                bat.id = naughty.notify({
                    preset = bat_notification_low_preset,
                    replaces_id = bat.id,
                }).id
            end
        end
    end

    newtimer(battery, timeout, update)

    return setmetatable(bat, { __index = bat.widget })
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
