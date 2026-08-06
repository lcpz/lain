--[[

     Licensed under GNU General Public License v3
      * (c) 2025, Mehmet Tekman <http://github.com/mtekman>

--]]

local helpers      = require("lain.helpers")
local wibox        = require("wibox")
local string       = string

-- Bluetooth Information
-- lain.widget.contrib.btinfo

local function factory(args)
    args             = args or {}

    local btinfo      = {widget = args.widget or wibox.widget.textbox()}
    local timeout    = args.timeout or 30
    local device_mac = args.device_mac or ""
    local settings   = args.settings or function() end

    function btinfo.update()
       helpers.async(
          string.format("bluetoothctl info '%s'", device_mac), function(f)
             bt_now = {
                name   = "N/A",
                icon    = "N/A",
                connected  = "N/A",
                paired   = "N/A",
                percentage  = "N/A"
             }

             for line in string.gmatch(f, "[^\n]+") do
                for k, v in string.gmatch(line, "([%w]+):[%s](.*)$") do
                   -- Matches only the last word before the colon in 'bluetoothctl info'
                   if     k == "Name"       then bt_now.name = v
                   elseif k == "Icon"       then bt_now.icon = v
                   elseif k == "Connected"  then bt_now.connected = (v == "yes")
                   elseif k == "Paired"     then bt_now.paired = (v == "yes")
                   elseif k == "Percentage" then bt_now.percentage = tonumber(string.match(v, "%(%s*(%d+)%)"))
                   end
                end
             end
             widget = btinfo.widget
             settings(bt_now)
       end)
    end
    btinfo.timer = helpers.newtimer("btinfo", timeout, btinfo.update, false, true)
    return btinfo
end

return factory
