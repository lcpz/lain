
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
      * (c) 2013, Rman                            
--]]

local newtimer     = require("lain.helpers").newtimer

local awful        = require("awful")
local beautiful    = require("beautiful")
local naughty      = require("naughty")

local io           = io
local math         = { modf  = math.modf }
local string       = { match = string.match,
                       rep   = string.rep }
local tonumber     = tonumber

local setmetatable = setmetatable

-- ALSA volume bar
-- lain.widgets.alsabar
local alsabar =
{
  channel = "Master",
  step = "5%",

  colors =
  {
     background = beautiful.bg_normal,
     mute   = "#EB8F8F",
     unmute = "#A4CE8A"
  },

  terminal = terminal or "xterm",
  mixer = terminal .. " -e alsamixer",

  notifications =
  {
     font = beautiful.font:sub(beautiful.font:find(""), beautiful.font:find(" ")),
     font_size = "11",
     color = beautiful.fg_focus,
     bar_size = 18 -- Awesome default
  },

  _current_level = 0,
  _muted = false
}

function alsabar:notify()
	local preset =
	{
      title = "", text = "",
      timeout = 15,
      font = alsabar.notifications.font .. " " .. alsabar.notifications.font_size,
      fg = alsabar.notifications.color
	}

	if alsabar._muted then
		preset.title = alsabar.channel .. " - Muted"
	else
		preset.title = alsabar.channel .. " - " .. alsabar._current_level * 100 .. "%"
	end

  local int = math.modf(alsabar._current_level * alsabar.notifications.bar_size)
  preset.text = "[" .. string.rep("|", int)
                .. string.rep(" ", alsabar.notifications.bar_size - int) .. "]"

  if alsabar._notify ~= nil then
		alsabar._notify = naughty.notify ({ replaces_id = alsabar._notify.id,
			                               preset = preset })
	else
		alsabar._notify = naughty.notify ({ preset = preset })
	end
end

local function worker(args)
    local args = args or {}
    local width = args.width or 63
    local height = args.heigth or 1
    local ticks = args.ticks or true
    local ticks_size = args.ticks_size or 7
    local vertical = args.vertical or false
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

    if vertical then
        alsabar.bar:set_vertical(true)
    end

    function update()
        -- Get mixer control contents
        local f = io.popen("amixer get " .. alsabar.channel)
        local mixer = f:read("*all")
        f:close()

        -- Capture mixer control state:          [5%] ... ... [on]
        local volu, mute = string.match(mixer, "([%d]+)%%.*%[([%l]*)") 

        if volu == nil then
            volu = 0
            mute = "off"
        end

        alsabar._current_level = tonumber(volu) / 100
        alsabar.bar:set_value(alsabar._current_level)

        if mute == "" and volu == "0" or mute == "off"
        then
            alsabar._muted = true
            alsabar.tooltip:set_text (" [Muted] ")
            alsabar.bar:set_color(alsabar.colors.mute)
        else
            alsabar._muted = false
            alsabar.tooltip:set_text(" " .. alsabar.channel .. ": " .. volu .. "% ")
            alsabar.bar:set_color(alsabar.colors.unmute)
        end
    end

    newtimer("alsabar", 5, update)

    alsabar.bar:buttons (awful.util.table.join (
          awful.button ({}, 1, function()
            awful.util.spawn(alsabar.mixer)
          end),
          awful.button ({}, 3, function()
            awful.util.spawn("amixer sset " .. alsabar.channel .. " toggle")
            myvolumebarupdate()
          end),
          awful.button ({}, 4, function()
            awful.util.spawn("amixer sset " .. alsabar.channel .. " "
                              .. alsabar.step .. "+")
            myvolumebarupdate()
          end),
          awful.button ({}, 5, function()
            awful.util.spawn("amixer sset " .. alsabar.channel .. " "
                              .. alsabar.step .. "-")
            myvolumebarupdate()
          end)
    ))

    return { 
        widget  = alsabar.bar,
        channel = alsabar.channel, 
        step    = alsabar.step,
        notify  = function() 
                    update()
                    alsabar.notify()
                  end
    }
end

return setmetatable(alsabar, { __call = function(_, ...) return worker(...) end })
