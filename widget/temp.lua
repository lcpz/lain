--[[

     Licensed under GNU General Public License v2
      * (c) 2013, Luca CPZ

--]]

local helpers  = require("lain.helpers")
local wibox    = require("wibox")
local tonumber = tonumber

-- coretemp
-- lain.widget.temp

local function factory(args)
    local temp         = { widget = wibox.widget.textbox() }
    local args         = args or {}
    local timeout      = args.timeout or 30
    local settings     = args.settings or function() end

    function temp.update()
        helpers.async({"find", "/sys/devices", "-name", "temp"}, function(f)
            temp_now = {}
            local temp_value
            for t in f:gmatch("[^\n]+") do
                temp_value = helpers.first_line(t)
                if temp_value then
                    temp_now[tonumber(t:match("%d+"))] = temp_value / 1e3
                end
            end
            coretemp_now = temp_now[0] or "N/A"
            widget = temp.widget
            settings()
        end)
    end

    helpers.newtimer("thermal", timeout, temp.update)

    return temp
end

return factory
