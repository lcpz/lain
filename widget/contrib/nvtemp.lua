local helpers = require("lain.helpers")
--local shell   = require("awful.util").shell
local wibox   = require("wibox")
local string  = string

-- Nvidia temperature
-- lain.widget.contrib.nvtemp

local function factory(args)
    args           = args or {}
    --local alsa     = { widget = args.widget or wibox.widget.textbox() }
    local nvtemp     = { widget = args.widget or wibox.widget.textbox() }
    local timeout  = args.timeout or 5
    local settings = args.settings or function() end

    --alsa.cmd           = args.cmd or "amixer"
    nvtemp.cmd           = args.cmd or "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader"
    --alsa.channel       = args.channel or "Master"
    --alsa.togglechannel = args.togglechannel

    --local format_cmd = string.format("%s get %s", alsa.cmd, alsa.channel)

    --[[
    if alsa.togglechannel then
        format_cmd = { shell, "-c", string.format("%s get %s; %s get %s",
        alsa.cmd, alsa.channel, alsa.cmd, alsa.togglechannel) }
    end
    --]]

    --alsa.last = {}

    --function alsa.update()
    function nvtemp.update()
        --helpers.async(format_cmd, function(mixer)
        helpers.async(nvtemp.cmd, function(temp)
            local l = temp
            l = tonumber(l)
            --if alsa.last.level ~= l or alsa.last.status ~= s then
                --volume_now = { level = l, status = s }
            nvtemp_now = l
            widget = nvtemp.widget
            settings()
            --alsa.last = volume_now
            --end
        end)
    end

    helpers.newtimer(string.format("foo"), timeout, nvtemp.update)

    return nvtemp
end

return factory
