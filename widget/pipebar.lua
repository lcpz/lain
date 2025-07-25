--[[

     Licensed under GNU General Public License v2
      * (c) 2013, Luca CPZ
      * (c) 2013, Rman
      * (c) 2025, Solodkiy

--]]

local helpers        = require("lain.helpers")
local awful          = require("awful")
local naughty        = require("naughty")
local wibox          = require("wibox")
local gears          = require("gears")
local math           = { modf   = math.modf,
                         floor  = math.floor }
local string         = { format = string.format,
                         match  = string.match,
                         gmatch = string.gmatch,
                         rep    = string.rep }
local type, tonumber = type, tonumber

-- PipeWire-compatible volume bar using wpctl
-- custom.widget.pipebar

local function factory(args)
    local pipebar = {
        colors = {
            background = "#000000",
            mute       = "#EB8F8F",
            unmute     = "#A4CE8A"
        },

        _current_level = 0,
        _mute          = "no",
        device         = "@DEFAULT_AUDIO_SINK@"
    }

    local args       = args or {}
    local timeout    = args.timeout or 5
    local settings   = args.settings or function() end
    local width      = args.width or 63
    local height     = args.height or 1
    local ticks      = args.ticks or false
    local ticks_size = args.ticks_size or 7

    pipebar.colors              = args.colors or pipebar.colors
    pipebar.followtag           = args.followtag or false
    pipebar.notification_preset = args.notification_preset or { font = "Monospace 10" }

    pipebar.bar = wibox.widget {
        forced_height    = height,
        forced_width     = width,
        color            = pipebar.colors.unmute,
        background_color = pipebar.colors.background,
        margins          = 1,
        paddings         = 1,
        ticks            = ticks,
        ticks_size       = ticks_size,
        widget           = wibox.widget.progressbar,
    }

    pipebar.tooltip = awful.tooltip({ objects = { pipebar.bar } })

    function pipebar.update(callback)
        helpers.async({ awful.util.shell, "-c", "wpctl get-volume " .. pipebar.device },
        function(s)
	    local vol, muted = string.match(s, "Volume:%s+([%d%.]+)%s*%[?([%u]*)%]?")
            vol = tonumber(vol)

            if not vol then return end

            pipebar._current_level = math.floor(vol * 100)
            pipebar._mute = (muted == "MUTED") and "yes" or "no"

            pipebar.bar:set_value(pipebar._current_level / 100)

            if pipebar._mute == "yes" or pipebar._current_level == 0 then
                pipebar.tooltip:set_text("[muted]")
                pipebar.bar.color = pipebar.colors.mute
            else
                pipebar.tooltip:set_text(string.format("volume: %d%%", pipebar._current_level))
                pipebar.bar.color = pipebar.colors.unmute
            end

            settings()
            if type(callback) == "function" then callback() end
        end)
    end

    function pipebar.notify()
        pipebar.update(function()
            local preset = pipebar.notification_preset

            preset.title = string.format("volume - %d%%", pipebar._current_level)

            if pipebar._mute == "yes" then
                preset.title = preset.title .. " muted"
            end

            local height = awful.screen.focused().mywibox.height
            local int = math.modf((pipebar._current_level / 100) * height)
            preset.text = string.format("[%s%s]", string.rep("|", int), string.rep(" ", height - int))

            if pipebar.followtag then preset.screen = awful.screen.focused() end

            if not pipebar.notification then
                pipebar.notification = naughty.notify {
                    preset  = preset,
                    destroy = function() pipebar.notification = nil end
                }
            else
                naughty.replace_text(pipebar.notification, preset.title, preset.text)
            end
        end)
    end

    pipebar.bar:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then -- left click
            awful.spawn("wpctl set-mute " .. pipebar.device .. " toggle")
            pipebar.update()
        elseif button == 4 then -- scroll up
            awful.spawn("wpctl set-volume " .. pipebar.device .. " 5%+")
            pipebar.update()
        elseif button == 5 then -- scroll down
            awful.spawn("wpctl set-volume " .. pipebar.device .. " 5%-")
            pipebar.update()
        end
    end)

    helpers.newtimer("pipebar", timeout, pipebar.update)

    return pipebar
end

return factory

