
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2016, Luke Bonham                     
                                                  
--]]

local read_pipe    = require("lain.helpers").read_pipe
local newtimer     = require("lain.helpers").newtimer
local wibox        = require("wibox")

local string       = { match  = string.match,
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

   pulseaudio.cmd    = args.cmd or string.format("pacmd list-sinks | sed -n -e '0,/*/d' -e '/base volume/d' -e '/volume:/p' -e '/muted:/p'")
   pulseaudio.sink_cmd = args.sink_cmd or string.format("pacmd list-sinks | gawk \'{\nif ($0 ~ /\\*\\ index/) {\nwhile ($0 !~ /device\\.string/) {\ngetline\n}\nprint gensub(/\\\"/,\"\",\"g\",$3)\nnext\n}\n}\'")
   pulseaudio.widget = wibox.widget.textbox('')

   function pulseaudio.update()
      if scallback then pulseaudio.cmd = scallback() end
      local s = read_pipe(pulseaudio.cmd)
      local sink = read_pipe(pulseaudio.sink_cmd)

      volume_now = {}
      volume_now.left  = tonumber(string.match(s, ":.-(%d+)%%"))
      volume_now.right = tonumber(string.match(s, ":.-(%d+)%%"))
      volume_now.muted = string.match(s, "muted: (%S+)")
      volume_now.sink = sink

      widget = pulseaudio.widget
      settings()
   end

   newtimer(string.format("pulseaudio-%s", timeout), timeout, pulseaudio.update)

   return setmetatable(pulseaudio, { __index = pulseaudio.widget })
end

return setmetatable(pulseaudio, { __call = function(_, ...) return worker(...) end })
