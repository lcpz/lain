
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
local tonumber     = tonumber

local setmetatable = setmetatable

-- Battery infos
-- lain.widgets.bat

local function worker(args)
	local bat      = {}
	local args     = args or {}
	local timeout  = args.timeout or 30
	local battery  = args.battery or "BAT0"
	local ac       = args.ac or "AC0"
	local notify   = args.notify or "on"
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

	function update()
		bat_now = {
			status    = "Not present",
			ac_status = "N/A",
			perc      = "N/A",
			time      = "N/A",
			watt      = "N/A"
		}

		local bstr    = "/sys/class/power_supply/" .. battery
		local astr    = "/sys/class/power_supply/" .. ac
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
						  
			-- energy_full(P)[uWh], charge_full(I)[uAh],                       
			local energy_full       = tonumber(first_line(bstr .. "/energy_full") or
										first_line(bstr .. "/charge_full"))


			local energy_percentage = tonumber(first_line(bstr .. "/capacity")) or
										math.floor((energy_now / energy_full) * 100)

			bat_now.status = first_line(bstr .. "/status") or "N/A"
			bat_now.ac_status     = first_line(astr .. "/online") or "N/A"

			-- if rate = 0 or rate not defined skip the round
			if	not (rate_power and rate_power > 0) and
				not (rate_current and  rate_current > 0) and
				not (bat_now.status == "Full")
			then
				return
			end
			
			local rate_time = 0
			if bat_now.status == "Charging"
			then
				rate_time = (energy_full - energy_now) / rate_power or rate_current
			elseif bat_now.status == "Discharging"
			then
				rate_time = energy_now / rate_power or rate_current
			end

			local hours   = math.floor(rate_time)
			local minutes = math.floor((rate_time - hours) * 60)

			bat_now.perc = string.format("%d", energy_percentage)
			bat_now.time = string.format("%02d:%02d", hours, minutes)
			bat_now.watt = string.format("%.2fW", rate_power / 1e6 or (rate_voltage * rate_current)  / 1e12)
		
		end
		widget = bat.widget
		settings()

		-- notifications for low and critical states
		if bat_now.status == "Discharging" and notify == "on" and bat_now.perc
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

	newtimer(battery, timeout, update)

	return setmetatable(bat, { __index = bat.widget })
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
