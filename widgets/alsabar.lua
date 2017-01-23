--[[
     Licensed under GNU General Public License v2
      * (c) 2013, Luke Bonham
      * (c) 2013, Rman
--]]

local helpers      = require("lain.helpers")
local awful        = require("awful")
local beautiful    = require("beautiful")
local naughty      = require("naughty")
local wibox        = require("wibox")
local math         = { modf   = math.modf }
local string       = { format = string.format,
                       match  = string.match,
                       rep    = string.rep }
local tonumber     = tonumber
local type         = type
local setmetatable = setmetatable
local terminal     = "urxvtc" or "xterm"

-- ALSA volume bar
-- lain.widgets.alsabar
local alsabar = {
    channel = "Master",
    step    = "1%",
    mixer   = "amixer",

    colors = {
        background = beautiful.bg_normal,
        mute       = "#EB8F8F",
        unmute     = "#A4CE8A"
    },

    notifications = {
        font      = beautiful.font:sub(beautiful.font:find(""), beautiful.font:find(" ")),
        font_size = "11",
        color     = beautiful.fg_normal,
        screen    = 1
    },

    _current_level = 0,
    _muted         = false
}

local function worker(args)
    local args         = args or {}
    local timeout      = args.timeout or 5
    local settings     = args.settings or function() end
    local width        = args.width or 63
    local height       = args.height or 1
    local ticks        = args.ticks or false
    local ticks_size   = args.ticks_size or 7
    local vertical     = args.vertical or false

    alsabar.mixer         = args.mixer or alsabar.mixer
    alsabar.channel       = args.channel or alsabar.channel
    alsabar.togglechannel = args.togglechannel or alsabar.togglechannel
    alsabar.cmd           = args.cmd or {"bash", "-c", string.format("%s get %s", alsabar.mixer, alsabar.channel)}
    alsabar.step          = args.step or alsabar.step
    alsabar.colors        = args.colors or alsabar.colors
    alsabar.notifications = args.notifications or alsabar.notifications
    alsabar.followtag     = args.followtag or false
    if alsabar.togglechannel then
            alsabar.cmd   = args.cmd or { "bash", "-c", string.format("%s get %s; %s get %s", alsabar.mixer, alsabar.channel, alsabar.mixer, alsabar.togglechannel)}
    end

    alsabar.bar = wibox.widget {
        forced_height    = height,
        forced_width     = width,
        color            = alsabar.colors.unmute,
        background_color = alsabar.colors.background,
        margins          = 1,
        paddings         = 1,
        ticks            = ticks,
        ticks_size       = ticks_size,
        widget           = wibox.widget.progressbar,
        layout           = vertical and wibox.container.rotate
    }

    alsabar.bar:buttons (awful.util.table.join(
        awful.button({}, 1, function()
                awful.spawn(string.format('%s -e alsamixer', terminal))
        end),
        awful.button({}, 2, function()
                awful.spawn(string.format("%s set %s 100%%", alsabar.mixer, alsabar.channel))
                alsabar.update()
        end),
        awful.button({}, 3, function()
                awful.spawn(string.format("%s set %s toggle", alsabar.mixer, alsabar.togglechannel or alsabar.channel))
                alsabar.update()
        end),
        awful.button({}, 4, function()
                awful.spawn(string.format("%s set %s %s+", alsabar.mixer, alsabar.channel, alsabar.step))
                alsabar.update()
        end),
        awful.button({}, 5, function()
                awful.spawn(string.format("%s set %s %s-", alsabar.mixer, alsabar.channel, alsabar.step))
                alsabar.update()
        end)))

    alsabar.tooltip = awful.tooltip({ objects = { alsabar.bar } })

    function alsabar.update(callback)
        helpers.async(alsabar.cmd, function(mixer)
            local volu,mute = string.match(mixer, "([%d]+)%%.*%[([%l]*)")
            if (volu and tonumber(volu) ~= alsabar._current_level) or (mute and string.match(mute, "on") ~= alsabar._muted)
            then
                alsabar._current_level = tonumber(volu) or alsabar._current_level
                alsabar.bar:set_value(alsabar._current_level / 100)
                if (not mute and tonumber(volu) == 0) or mute == "off"
                then
                    alsabar._muted = true
                    alsabar.tooltip:set_text ("[Muted]")
                    alsabar.bar.color = alsabar.colors.mute
                else
                    alsabar._muted = false
                    alsabar.tooltip:set_text(string.format("%s: %s", alsabar.channel, volu))
                    alsabar.bar.color = alsabar.colors.unmute
                end

                volume_now = {}
                volume_now.level = tonumber(volu)
                volume_now.status = mute

                settings()

                if type(callback) == "function" then callback() end
            end
        end)
    end

    function alsabar.notify()
        alsabar.update(function()
            local preset = {
                title   = "",
                text    = "",
                timeout = 5,
                screen  = alsabar.notifications.screen,
                font    = string.format("%s %s", alsabar.notifications.font,
                          alsabar.notifications.font_size),
                fg      = alsabar.notifications.color
            }

            if alsabar._muted then
                preset.title = string.format("%s - Muted", alsabar.channel)
            else
                preset.title = string.format("%s - %s%%", alsabar.channel, alsabar._current_level)
            end

            int = math.modf((alsabar._current_level / 100) * awful.screen.focused().mywibox.height)
            preset.text = string.format("[%s%s]", string.rep("|", int),
                          string.rep(" ", awful.screen.focused().mywibox.height - int))

            if alsabar.followtag then preset.screen = awful.screen.focused() end

            if alsabar._notify then
                alsabar._notify = naughty.notify ({
                    replaces_id = alsabar._notify.id,
                    preset      = preset,
                })
            else
                alsabar._notify = naughty.notify ({ preset = preset })
            end
        end)
    end

    timer_id = string.format("alsabar-%s-%s", alsabar.cmd, alsabar.channel)
    helpers.newtimer(timer_id, timeout, alsabar.update)

    return alsabar
end

return setmetatable(alsabar, { __call = function(_, ...) return worker(...) end })
