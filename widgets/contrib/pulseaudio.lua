
local helpers         = require("lain.helpers")
local newtimer        = require("lain.helpers").newtimer
local read_pipe       = require("lain.helpers").read_pipe
local wibox           = require("wibox")
local string          = { match  = string.match,
                          format = string.format }

local beautiful    = require("beautiful")
local naughty      = require("naughty")


local setmetatable    = setmetatable

local pacmd = "pacmd"
local pactl = "pactl"
local default_sink = "alsa_output.pci-0000_00_1b.0.analog-stereo"

-- ALSA volume
-- lain.widgets.alsa
local pulseaudio = {}
local pulseaudio_notification  = nil

local function worker(args)
   local args     = args or {}
   local timeout  = args.timeout or 10
   local settings = args.settings or function() end

   pulseaudio.cmd     = args.cmd or "pacmd"
   pulseaudio.widget = wibox.widget.textbox('')
   pulseaudio.level   = 0
   pulseaudio.status  = "on"
   pulseaudio.sink    = args.sink or default_sink

   function pulseaudio.get_sink()
      local f = io.popen(pacmd .. " dump | /bin/grep -v -e '^$' | /bin/grep -v load")
      local sink = nil

      while true  do
         line = f:read("*l")
         if line == nil then break end
         sink = string.match(line, "set%-default%-sink ([^\n]+)")
         if sink ~= nil then
            return sink
         end
      end
      f:close()
      return nil    
   end
   
   function pulseaudio.update()
      -- Get default sink
      default_sink = pulseaudio.get_sink()
      
      local f = io.popen(pacmd .. " dump | /bin/grep -v -e '^$' | /bin/grep -v load")
      local self = {}
      volume_now = {}
            
      -- if the cmd can't be found
      if f == nil then
         return false
      end
      
      while true  do
         line = f:read("*l")
         if line == nil then break end
         
         sink, value = string.match(line, "set%-sink%-volume ([^%s]+) (0x%x+)")
         if sink == default_sink and value ~= 0  then
            volume_now.level = round((tonumber(value) / 0x10000) * 100)
         end


         sink, value = string.match(line, "set%-sink%-mute ([^%s]+) (%a+)")
         if sink == default_sink and value == "no" then
            volume_now.status = "on"
         elseif sink == default_sink and value == "yes" then
            volume_now.status = "off"
         end
      end

      f:close()

      if volume_now.level == nil
      then
         volume_now.level  = "0"
         volume_now.status = "off"
      end
      if volume_now.status == ""
      then
         volume_now.status = "off"
      end

      widget = pulseaudio.widget
      widget:set_markup(markup("#7493d2", volume_now.level .. "% "))
      settings()
      
      pulseaudio.level = volume_now.level
      pulseaudio.status = volume_now.status
      
   end

   
   function round(num,idp)
      local mult = 10^(idp or 0)
      return math.floor(num*mult+0.5)/mult
   end

   function pulseaudio.up()
      os.execute(pactl .. " set-sink-volume " .. default_sink .. " +10%")
      pulseaudio.update()
      
      return pulseaudio.level 
   end

   function pulseaudio.down()
      os.execute(pactl .. " set-sink-volume " .. default_sink .. " -10%")
      pulseaudio.update()
      return pulseaudio.level 
   end

   function pulseaudio.toggle()
      if pulseaudio.status == "off" then
         os.execute(pactl .. " set-sink-mute " .. default_sink .. " no")
      else
         os.execute(pactl .. " set-sink-mute " .. default_sink .. " yes")
      end
      pulseaudio.update()
      if pulseaudio.status == "off" then
         return 0
      else
         return pulseaudio.level
      end
   end

   timer_id = string.format("pulseaudio-%s", pulseaudio.sink)
   newtimer(timer_id, timeout, pulseaudio.update)
   return setmetatable(pulseaudio, { __index = pulseaudio.widget })
end


return setmetatable(pulseaudio, { __call = function(_, ...) return worker(...) end })

