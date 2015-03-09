
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
      * (c) 2013, Rman                            
                                                  
--]]

local newtimer     = require("lain.helpers").newtimer

local awful        = require("awful")
local beautiful    = require("beautiful")
local naughty      = require("naughty")

local io           = { popen  = io.popen }
local math         = { modf   = math.modf }
local string       = { format = string.format,
                       match  = string.match,
                       rep    = string.rep }
local tonumber     = tonumber

local setmetatable = setmetatable

-- ALSA volume bar
-- lain.widgets.alsabar
local alsabar = {
    card    = "0",
    channel = "Master",
    step    = "5%",

    colors = {
        background = beautiful.bg_normal,
        mute       = "#EB8F8F",
        unmute     = "#A4CE8A"
    },

    terminal = terminal or "xterm",
    mixer    = terminal .. " -e alsamixer",

    notifications = {
        -- notification preset
        preset = {
            font      = beautiful.font:sub(beautiful.font:find(""), beautiful.font:find(" ")),
            font_size = "11",
            color     = beautiful.fg_normal,
            screen    = 1
        },
        -- slider parameters
        bar = {
	    size  = 18,
	    fill = "|",
	    empty = " ",
	},
    },

    _current_level = 0,
    _muted         = false
}

-- slider drawing function
alsabar.notifications.bar.draw = function(int)
    return string.format("[%s%s]",
        string.rep(alsabar.notifications.bar.fill, int),
        string.rep(alsabar.notifications.bar.empty,
            alsabar.notifications.bar.size - int)
    )
end

function alsabar.notify()
    alsabar.update()

    local title = alsabar.channel.." - "
    if alsabar._muted then title = title.."Muted"
    else title = title..alsabar._current_level.."%" end

    local int = math.modf((alsabar._current_level / 100) *
        alsabar.notifications.bar.size)
    local text = alsabar.notifications.bar.draw(int)

    local id = nil
    if alsabar._notify then id = alsabar._notify.id end
    alsabar._notify = naughty.notify ({
        title = title,
        text = text,
        preset = alsabar.notifications.preset,
        replaces_id = id,
    })
end

local function worker(args)
    local args = args or {}
    local timeout = args.timeout or 4
    local settings = args.settings or function() end
    local width = args.width or 63
    local height = args.heigth or 1
    local ticks = args.ticks or false
    local ticks_size = args.ticks_size or 7
    local vertical = args.vertical or false

    alsabar.card = args.card or alsabar.card
    alsabar.channel = args.channel or alsabar.channel
    alsabar.step = args.step or alsabar.step
    alsabar.colors = args.colors or alsabar.colors
    alsabar.notifications = args.notifications or alsabar.notifications

    alsabar.bar = awful.widget.progressbar()

    alsabar.bar:set_background_color(alsabar.colors.background)
    alsabar.bar:set_color(alsabar.colors.unmute)
    alsabar.tooltip = awful.tooltip({ objects = { alsabar.bar } })
    alsabar.bar:set_width(width)
    alsabar.bar:set_height(height)
    alsabar.bar:set_ticks(ticks)
    alsabar.bar:set_ticks_size(ticks_size)
    alsabar.bar:set_vertical(vertical)

    function alsabar.update()
        -- Get mixer control contents
        local f = assert(io.popen(string.format("amixer -c %s -M get %s", alsabar.card, alsabar.channel)))
        local mixer = f:read("*a")
        f:close()

        -- Capture mixer control state:          [5%] ... ... [on]
        local volu, mute = string.match(mixer, "([%d]+)%%.*%[([%l]*)")

        if volu == nil then
            volu = 0
            mute = "off"
        end

        alsabar._current_level = tonumber(volu)
        alsabar.bar:set_value(alsabar._current_level / 100)
        if not mute and tonumber(volu) == 0 or mute == "off"
        then
            alsabar._muted = true
            alsabar.tooltip:set_text (" [Muted] ")
            alsabar.bar:set_color(alsabar.colors.mute)
        else
            alsabar._muted = false
            alsabar.tooltip:set_text(string.format(" %s:%s ", alsabar.channel, volu))
            alsabar.bar:set_color(alsabar.colors.unmute)
        end

        volume_now = {}
        volume_now.level = tonumber(volu)
        volume_now.status = mute
        settings()
    end

    newtimer("alsabar", timeout, alsabar.update)

    alsabar.bar:buttons (awful.util.table.join (
          awful.button ({}, 1, function()
            awful.util.spawn(alsabar.mixer)
          end),
          awful.button ({}, 3, function()
            awful.util.spawn(string.format("amixer -c %s set %s toggle", alsabar.card, alsabar.channel))
            alsabar.update()
          end),
          awful.button ({}, 4, function()
            awful.util.spawn(string.format("amixer -c %s set %s %s+", alsabar.card, alsabar.channel, alsabar.step))
            alsabar.update()
          end),
          awful.button ({}, 5, function()
            awful.util.spawn(string.format("amixer -c %s set %s %s-", alsabar.card, alsabar.channel, alsabar.step))
            alsabar.update()
          end)
    ))

    return alsabar
end

return setmetatable(alsabar, { __call = function(_, ...) return worker(...) end })
