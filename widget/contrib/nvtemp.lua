local helpers = require("lain.helpers")
local wibox   = require("wibox")
local string  = string

-- Nvidia temperature
-- lain.widget.contrib.nvtemp

local function factory(args)
    args           = args or {}
    local nvtemp     = { widget = args.widget or wibox.widget.textbox() }
    local timeout  = args.timeout or 5
    local settings = args.settings or function() end

    nvtemp.cmd           = "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader"

    function nvtemp.update()
        helpers.async(nvtemp.cmd, function(temp)
            temp = tonumber(temp)
            nvtemp_now = temp
            widget = nvtemp.widget
            settings()
        end)
    end

    helpers.newtimer(string.format("nvidia_temp"), timeout, nvtemp.update)

    return nvtemp
end

return factory
