
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
      * (c) 2013, Rman                            
                                                  
--]]

local newtimer     = require("lain.helpers").newtimer
local read_pipe    = require("lain.helpers").read_pipe

local awful        = require("awful")
local beautiful    = require("beautiful")
local naughty      = require("naughty")

local math         = { modf   = math.modf }
local mouse        = mouse
local string       = { format = string.format,
                       match  = string.match,
                       rep    = string.rep }
local tonumber     = tonumber

local setmetatable = setmetatable

-- ALSA volume bar
-- lain.widgets.pulsebar
local pulsebar = {
    sink = 0,
    step = "1%",

    colors = {
        background = beautiful.bg_normal,
        mute       = "#EB8F8F",
        unmute     = "#A4CE8A"
    },

    mixer = "pavucontrol",

    notifications = {
        font      = beautiful.font:sub(beautiful.font:find(""), beautiful.font:find(" ")),
        font_size = "11",
        color     = beautiful.fg_normal,
        bar_size  = 18,
        screen    = 1
    },

    _current_level = 0,
    _muted         = false
}

function pulsebar.notify()
    pulsebar.update()

    local preset = {
        title   = "",
        text    = "",
        timeout = 5,
        screen  = pulsebar.notifications.screen,
        font    = pulsebar.notifications.font .. " " ..
                  pulsebar.notifications.font_size,
        fg      = pulsebar.notifications.color
    }

    if pulsebar._muted
    then
        preset.title = "Sink " .. pulsebar.sink .. " - Muted"
    else
        preset.title = "Sink " .. pulsebar.sink .. " - " .. pulsebar._current_level .. "%"
    end

    int = math.modf((pulsebar._current_level / 100) * pulsebar.notifications.bar_size)
    preset.text = "["
                .. string.rep("|", int)
                .. string.rep(" ", pulsebar.notifications.bar_size - int)
                .. "]"

    if pulsebar.followmouse then
        preset.screen = mouse.screen
    end

    if pulsebar._notify ~= nil then
        pulsebar._notify = naughty.notify ({
            replaces_id = pulsebar._notify.id,
            preset      = preset,
        })
    else
        pulsebar._notify = naughty.notify ({
            preset = preset,
        })
    end
end

local function worker(args)
    local args       = args or {}
    local timeout    = args.timeout or 5
    local settings   = args.settings or function() end
    local width      = args.width or 63
    local height     = args.heigth or 1
    local ticks      = args.ticks or false
    local ticks_size = args.ticks_size or 7
    local vertical   = args.vertical or false
    local scallback  = args.scallback

    pulsebar.cmd           = args.cmd or string.format("pacmd list-sinks | sed -n -e '0,/*/d' -e '/base volume/d' -e '/volume:/p' -e '/muted:/p'")
    pulsebar.colors        = args.colors or pulsebar.colors
    pulsebar.notifications = args.notifications or pulsebar.notifications
    pulsebar.sink          = args.sink or 0
    pulsebar.step          = args.step or pulsebar.step
    pulsebar.followmouse   = args.followmouse or false

    pulsebar.bar = awful.widget.progressbar()

    pulsebar.bar:set_background_color(pulsebar.colors.background)
    pulsebar.bar:set_color(pulsebar.colors.unmute)
    pulsebar.tooltip = awful.tooltip({ objects = { pulsebar.bar } })
    pulsebar.bar:set_width(width)
    pulsebar.bar:set_height(height)
    pulsebar.bar:set_ticks(ticks)
    pulsebar.bar:set_ticks_size(ticks_size)
    pulsebar.bar:set_vertical(vertical)

    function pulsebar.update()
        if scallback then pulseaudio.cmd = scallback() end
        local s = read_pipe(pulsebar.cmd)

        volume_now = {}
        volume_now.left  = tonumber(string.match(s, ":.-(%d+)%%"))
        volume_now.right = tonumber(string.match(s, ":.-(%d+)%%"))
        volume_now.muted = string.match(s, "muted: (%S+)")

        local volu = volume_now.left
        local mute = volume_now.muted

        if (volu and volu ~= pulsebar._current_level) or (mute and mute ~= pulsebar._muted)
        then
            pulsebar._current_level = volu
            pulsebar.bar:set_value(pulsebar._current_level / 100)
            if not mute and volu == 0 or mute == "yes"
            then
                pulsebar._muted = true
                pulsebar.tooltip:set_text (" [Muted] ")
                pulsebar.bar:set_color(pulsebar.colors.mute)
            else
                pulsebar._muted = false
                pulsebar.tooltip:set_text(string.format(" %s:%s ", pulsebar.sink, volu))
                pulsebar.bar:set_color(pulsebar.colors.unmute)
            end
            settings()
        end
    end

    pulsebar.bar:buttons(awful.util.table.join (
          awful.button({}, 1, function()
            awful.util.spawn(pulsebar.mixer)
          end),
          awful.button({}, 2, function()
						awful.util.spawn(string.format("pactl set-sink-volume %d 100%%", pulsebar.sink))
            pulsebar.update()
          end),
          awful.button({}, 3, function()
						awful.util.spawn(string.format("pactl set-sink-mute %d toggle", pulsebar.sink))
            pulsebar.update()
          end),
          awful.button({}, 4, function()
						awful.util.spawn(string.format("pactl set-sink-volume %d +%s", pulsebar.sink, pulsebar.step))
            pulsebar.update()
          end),
          awful.button({}, 5, function()
						awful.util.spawn(string.format("pactl set-sink-volume %d -%s", pulsebar.sink, pulsebar.step))
            pulsebar.update()
					end)
    ))

    timer_id = string.format("pulsebar-%s", pulsebar.sink)

    newtimer(timer_id, timeout, pulsebar.update)

    return pulsebar
end

return setmetatable(pulsebar, { __call = function(_, ...) return worker(...) end })
