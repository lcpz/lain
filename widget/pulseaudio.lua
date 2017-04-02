
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2016, Luke Bonham                     
                                                  
--]]

local helpers = require("lain.helpers")
local shell   = require("awful.util").shell
local wibox   = require("wibox")
local string  = { gmatch = string.gmatch,
                  match  = string.match,
                  format = string.format }

-- PulseAudio volume
-- lain.widget.pulseaudio

local function factory(args)
    local pulseaudio  = { widget = wibox.widget.textbox() }
    local args        = args or {}
    local timeout     = args.timeout or 5
    local settings    = args.settings or function() end
    local scallback   = args.scallback
 
    pulseaudio.device = "N/A"
    pulseaudio.devicetype = args.devicetype or "sink"
    pulseaudio.cmd = args.cmd or "pacmd list-" .. pulseaudio.devicetype .. "s | sed -n -e '0,/*/d' -e '/base volume/d' -e '/volume:/p' -e '/muted:/p' -e '/device\\.string/p'"

    function pulseaudio.update()
        if scallback then pulseaudio.cmd = scallback() end

        helpers.async({ shell, "-c", pulseaudio.cmd }, function(s)
            volume_now = {
                index = string.match(s, "index: (%S+)") or "N/A",
                device = string.match(s, "device.string = \"(%S+)\"") or "N/A",
                sink   = device, -- legacy API
                muted  = string.match(s, "muted: (%S+)") or "N/A"
            }

            pulseaudio.device = volume_now.index

            local ch = 1
            volume_now.channel = {}
            for v in string.gmatch(s, ":.-(%d+)%%") do
                volume_now.channel[ch] = v
                ch = ch + 1
            end

            volume_now.left  = volume_now.channel[1] or "N/A"
            volume_now.right = volume_now.channel[2] or "N/A"

            widget = pulseaudio.widget

            settings()
        end)
    end

    helpers.newtimer("pulseaudio", timeout, pulseaudio.update)

    return pulseaudio
end

return factory
