
--[[
												                        
	 Licensed under GNU General Public License v2 
	  * (c) 2013,      Luke Bonham                
	  * (c) 2010-2012, Peter Hofmann              
												                        
--]]

local first_line = require("lain.helpers").first_line
local newtimer   = require("lain.helpers").newtimer
local naughty    = require("naughty")
local wibox      = require("wibox")
local math       = { abs    = math.abs,
                     floor  = math.floor,
                     log10  = math.log10,
                     min    = math.min }
local string     = { format = string.format }
local ipairs     = ipairs
local tonumber   = tonumber

-- Battery infos
-- lain.widget.bat

local function factory(args)
    local bat       = { widget = wibox.widget.textbox() }
    local args      = args or {}
    local timeout   = args.timeout or 30
    local batteries = args.batteries or (args.battery and {args.battery}) or {"BAT0"}
    local ac        = args.ac or "AC0"
    local notify    = args.notify or "on"
    local n_perc    = args.n_perc or { 5, 15 }
    local settings  = args.settings or function() end

    bat_notification_critical_preset = {
        title   = "Battery exhausted",
        text    = "Shutdown imminent",
        timeout = 15,
        fg      = "#000000",
        bg      = "#FFFFFF"
    }

    bat_notification_low_preset = {
        title   = "Battery low",
        text    = "Plug the cable!",
        timeout = 15,
        fg      = "#202020",
        bg      = "#CDCDCD"
    }

    bat_now = {
        status    = "N/A",
        ac_status = "N/A",
        perc      = "N/A",
        time      = "N/A",
        watt      = "N/A"
    }

    bat_now.n_status = {}
    bat_now.n_perc   = {}
    for i = 1, #batteries do
        bat_now.n_status[i] = "N/A"
        bat_now.n_perc[i] = 0
    end

    function bat.update()
        local sum_rate_current = 0
        local sum_rate_voltage = 0
        local sum_rate_power   = 0
        local sum_rate_energy  = 0
        local sum_energy_now   = 0
        local sum_energy_full  = 0
        local pspath           = "/sys/class/power_supply/"

        for i, battery in ipairs(batteries) do
            local bstr    = pspath .. battery
            local present = first_line(bstr .. "/present")

            if tonumber(present) == 1 then
                -- current_now(I)[uA], voltage_now(U)[uV], power_now(P)[uW]
                local rate_current = tonumber(first_line(bstr .. "/current_now"))
                local rate_voltage = tonumber(first_line(bstr .. "/voltage_now"))
                local rate_power   = tonumber(first_line(bstr .. "/power_now"))

                -- energy_now(P)[uWh], charge_now(I)[uAh]
                local energy_now        = tonumber(first_line(bstr .. "/energy_now") or
                                          first_line(bstr .. "/charge_now"))

                -- energy_full(P)[uWh], charge_full(I)[uAh]
                local energy_full       = tonumber(first_line(bstr .. "/energy_full") or
                                          first_line(bstr .. "/charge_full"))

                local energy_percentage = tonumber(first_line(bstr .. "/capacity")) or
                                          math.floor((energy_now / energy_full) * 100)

                bat_now.n_status[i] = first_line(bstr .. "/status") or "N/A"
                bat_now.n_perc[i]   = energy_percentage or bat_now.n_perc[i]

                sum_rate_current = sum_rate_current + (rate_current or 0)
                sum_rate_voltage = sum_rate_voltage + (rate_voltage or 0)
                sum_rate_power   = sum_rate_power + (rate_power or 0)
                sum_rate_energy  = sum_rate_energy + (rate_power or (((rate_voltage or 0) * (rate_current or 0)) / 1e6))
                sum_energy_now   = sum_energy_now + (energy_now or 0)
                sum_energy_full  = sum_energy_full + (energy_full or 0)
            end
        end

        -- When one of the battery is charging, others' status are either
        -- "Full", "Unknown" or "Charging". When the laptop is not plugged in,
        -- one or more of the batteries may be full, but only one battery
        -- discharging suffices to set global status to "Discharging".
        bat_now.status = bat_now.n_status[1]
        for _,status in ipairs(bat_now.n_status) do
            if status == "Discharging" or status == "Charging" then
                bat_now.status = status
            end
        end
        bat_now.ac_status = tonumber(first_line(string.format("%s%s/online", pspath, ac))) or "N/A"

        if bat_now.status ~= "N/A" then
            if bat_now.status ~= "Full" and sum_rate_power == 0 and bat_now.ac_status == 1 then
                bat_now.perc  = math.floor(math.min(100, (sum_energy_now / sum_energy_full) * 100))
                bat_now.time  = "00:00"
                bat_now.watt  = 0

            -- update {perc,time,watt} iff battery not full and rate > 0
            elseif bat_now.status ~= "Full" then
                local rate_time = 0
                -- Calculate time and watt if rates are greater then 0
                if (sum_rate_power > 0 or sum_rate_current > 0) then
                    local div = (sum_rate_power > 0 and sum_rate_power) or sum_rate_current

                    if bat_now.status == "Charging" then
                        rate_time = (sum_energy_full - sum_energy_now) / div
                    else -- Discharging
                        rate_time = sum_energy_now / div
                    end

                    if 0 < rate_time and rate_time < 0.01 then -- check for magnitude discrepancies (#199)
                        rate_time_magnitude = math.abs(math.floor(math.log10(rate_time)))
                        rate_time = rate_time * 10^(rate_time_magnitude - 2)
                    end
                 end

                local hours   = math.floor(rate_time)
                local minutes = math.floor((rate_time - hours) * 60)
                bat_now.perc  = math.floor(math.min(100, (sum_energy_now / sum_energy_full) * 100))
                bat_now.time  = string.format("%02d:%02d", hours, minutes)
                bat_now.watt  = tonumber(string.format("%.2f", sum_rate_energy / 1e6))
            elseif bat_now.status == "Full" then
                bat_now.perc  = 100
                bat_now.time  = "00:00"
                bat_now.watt  = 0
            end
        end

        widget = bat.widget
        settings()

        -- notifications for critical and low levels
        if notify == "on" and bat_now.status == "Discharging" then
            if tonumber(bat_now.perc) <= n_perc[1] then
                bat.id = naughty.notify({
                    preset = bat_notification_critical_preset,
                    replaces_id = bat.id
                }).id
            elseif tonumber(bat_now.perc) <= n_perc[2] then
                bat.id = naughty.notify({
                    preset = bat_notification_low_preset,
                    replaces_id = bat.id
                }).id
            end
        end
    end

    newtimer("batteries", timeout, bat.update)

    return bat
end

return factory
