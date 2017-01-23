
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2016, Luke Bonham                     
                                                  
--]]

local helpers      = require("lain.helpers")
local shell        = require("awful.util").shell
local wibox        = require("wibox")
local string       = { gmatch = string.gmatch,
                       match  = string.match,
                       format = string.format }
local setmetatable = setmetatable

-- PulseAudio volume
-- lain.widgets.pulseaudio
local pulseaudio = {}

local function worker(args)
   local args        = args or {}
   local timeout     = args.timeout or 5
   local settings    = args.settings or function() end
   local scallback   = args.scallback

   pulseaudio.cmd    = args.cmd or "pacmd list-sinks | sed -n -e '0,/*/d' -e '/base volume/d' -e '/volume:/p' -e '/muted:/p' -e '/device\\.string/p'"
   pulseaudio.widget = wibox.widget.textbox()

   function pulseaudio.update()
      if scallback then pulseaudio.cmd = scallback() end

      helpers.async({ shell, "-c", pulseaudio.cmd }, function(s)
          volume_now = {
              index = string.match(s, "index: (%S+)") or "N/A",
              sink  = string.match(s, "device.string = \"(%S+)\"") or "N/A",
              muted = string.match(s, "muted: (%S+)") or "N/A"
          }

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

   helpers.newtimer(string.format("pulseaudio-%s", timeout), timeout, pulseaudio.update)

   return setmetatable(pulseaudio, { __index = pulseaudio.widget })
end

return setmetatable(pulseaudio, { __call = function(_, ...) return worker(...) end })
