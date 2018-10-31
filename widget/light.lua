--[[

     Licensed under GNU General Public License v2
      * (c) 2018, Matheus Teixeira

--]]

local helpers        = require("lain.helpers")
local awful          = require("awful")
local naughty        = require("naughty")
local wibox          = require("wibox")
local math           = { modf   = math.modf }
local string         = { format = string.format,
                         match  = string.match,
                         rep    = string.rep }
local type, tonumber = type, tonumber

-- lain.widget.light

local function factory(args)
    local light = {
        colors = {
            background = "#000000",
        },

        _current_level = 0,
    }

    local args       = args or {}
    local timeout    = args.timeout or 5
    local settings   = args.settings or function() end

    light.cmd                 = args.cmd or "light"
    light.colors              = args.colors or light.colors
    light.followtag           = args.followtag or false
    light.notification_preset = args.notification_preset

    if not light.notification_preset then
        light.notification_preset      = {}
        light.notification_preset.font = "Monospace 10"
    end

    local format_get_cmd = string.format("%s -G", light.cmd)

    light.widget = wibox.widget {
        background_color = light.colors.background,
        widget           = wibox.widget.textbox()
    }

    light.tooltip = awful.tooltip({ objects = { light.widget } })

    function light.update(callback)
        helpers.async(format_get_cmd, function(value)
            if not value  then return end

            if value ~= light._current_level then
                light._current_level = tonumber(value)
                light.widget:set_text(string.format("%03d%%", light._current_level))
                light.tooltip:set_text(string.format("%s: %3d%%", 'Light', light._current_level))

                light_now = {
                    level = tonumber(string.format("%d", light._current_level)),
                }
                widget = light.widget
                settings()

                if type(callback) == "function" then callback() end
            end
        end)
    end

    function light.notify()
        light.update(function()
            local preset = light.notification_preset

            preset.title = string.format("%s - %s%%", 'Light', light._current_level)

            -- tot is the maximum number of ticks to display in the notification
            -- fallback: default horizontal wibox height
            local wib, tot = awful.screen.focused().mywibox, 20

            -- if we can grab mywibox, tot is defined as its height if
            -- horizontal, or width otherwise
            if wib then
                if wib.position == "left" or wib.position == "right" then
                    tot = wib.width
                else
                    tot = wib.height
                end
            end

            int = math.modf((light._current_level / 100) * tot)
            preset.text = string.format("[%s%s]", string.rep("|", int),
                          string.rep(" ", tot - int))

            if light.followtag then preset.screen = awful.screen.focused() end

            if not light.notification then
                light.notification = naughty.notify {
                    preset  = preset,
                    destroy = function() light.notification = nil end
                }
            else
                naughty.replace_text(light.notification, preset.title, preset.text)
            end
        end)
    end

    helpers.newtimer(string.format("light-%s", light.cmd), timeout, light.update)

    return light
end

return factory
