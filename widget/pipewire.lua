--[[

     Licensed under GNU General Public License v2
      * (c) 2016, Luca CPZ

--]]

local helpers = require("lain.helpers")
local shell   = require("awful.util").shell
local wibox   = require("wibox")
local string  = string
local type    = type

-- pipewire volume
-- lain.widget.pipewire

local function factory(args)
    args = args or {}

    local pipewire = { widget = args.widget or wibox.widget.textbox(), device = "N/A" }
    local timeout  = args.timeout or 5
    local settings = args.settings or function() end

    pipewire.devicetype = args.devicetype or "sink"
    volume_now = {}

    function pipewire.update()
        helpers.async({ "bash", "-c", string.format("pactl list %ss | grep -A 1 'Name: '$(pactl get-default-%s)", pipewire.devicetype, pipewire.devicetype) }, function(s)
            volume_now.device = string.match(s, "Description: (%S+)") or "N/A"
        end)

        helpers.async({ shell, "-c", string.format("pactl get-%s-mute @DEFAULT_%s@", pipewire.devicetype, string.upper(pipewire.devicetype)) }, function(s)
            volume_now.muted = string.match(s, "Mute: (%S+)") or "N/A"
        end)

        helpers.async({ shell, "-c", string.format("pactl get-%s-volume @DEFAULT_%s@", pipewire.devicetype, string.upper(pipewire.devicetype)) }, function(t)
            volume_now.channel = {}
            for v in string.gmatch(t, ":.-(%d+)%%") do
                volume_now.channel[#volume_now.channel + 1] = v
            end

            volume_now.left  = volume_now.channel[1] or "N/A"
            volume_now.right = volume_now.channel[2] or "N/A"

            widget = pipewire.widget
            settings()
        end)
    end

    helpers.newtimer("pipewire", timeout, pipewire.update)

    return pipewire
end

return factory
