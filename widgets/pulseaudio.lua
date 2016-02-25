
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2016, Luke Bonham                     
                                                  
--]]

local read_pipe       = require("lain.helpers").read_pipe
local newtimer        = require("lain.helpers").newtimer
local wibox           = require("wibox")

local string          = { match  = string.match,
                          format = string.format }

local setmetatable    = setmetatable

-- PulseAudio volume
-- lain.widgets.pulseaudio
local pulseaudio = {}

local function worker(args)
   local args        = args or {}
   local timeout     = args.timeout or 5
   local settings    = args.settings or function() end
   local scallback   = args.scallback or nil

   pulseaudio.sink   = args.sink or 0 -- user defined or first one
   pulseaudio.cmd    = args.cmd or string.format("pacmd list-sinks | sed -n -e '/base volume/d' -e '/index: %d/p' -e '/volume:/p' -e '/muted:/p' | sed -n -e '/index: %d/,+2p'",
                       pulseaudio.sink, pulseaudio.sink)
   pulseaudio.widget = wibox.widget.textbox('')

   function pulseaudio.update()
      local s = read_pipe(pulseaudio.cmd)

      volume_now = {}
      volume_now.left  = tonumber(string.match(s, "left.-(%d+)%%")) or tonumber(string.match(s, "0:.-(%d+)%%"))
      volume_now.right = tonumber(string.match(s, "right.-(%d+)%%")) or tonumber(string.match(s, "1:.-(%d+)%%"))
      volume_now.muted = string.match(s, "muted: (%S+)")

      if scallback ~= nil then
         pulseaudio.sink   = scallback()
      end

      widget = pulseaudio.widget
      settings()
   end

   newtimer(string.format("pulseaudio-%s", pulseaudio.sink), timeout, pulseaudio.update)

   return setmetatable(pulseaudio, { __index = pulseaudio.widget })
end

return setmetatable(pulseaudio, { __call = function(_, ...) return worker(...) end })
