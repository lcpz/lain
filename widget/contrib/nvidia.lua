--[[

     Licensed under GNU General Public License v2
      * (c) 2013, Luca CPZ
      * (c) 2022, tronfy <https://github.com/tronfy>

--]]

local helpers  = require("lain.helpers")
local wibox    = require("wibox")

-- NVIDIA GPU usage/temperature info (requires nvidia-smi)
-- lain.widget.contrib.nvidia

local function factory(args)
    args           = args or {}

    local nvidia   = { widget = args.widget or wibox.widget.textbox() }
    local timeout  = args.timeout or 5
    local exec     = args.exec or "nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits"
    local format   = args.format or "%.1f"
    local settings = args.settings or function() end

    function nvidia.update()
        gpu = {
            usage = "N/A",
            temp  = "N/A"
        }

        helpers.async(exec, function(f)
            -- f -> "usage, temp"
            gpu.usage, gpu.temp = f:match("([^,]+),([^,]+)")
            gpu.temp = string.format(format, gpu.temp)

            widget = nvidia.widget
            settings()
        end)
    end

    helpers.newtimer("nvidia-gpu", timeout, nvidia.update)

    return nvidia
end

return factory
