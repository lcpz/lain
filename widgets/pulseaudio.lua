
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2016, Luke Bonham                     
                                                  
--]]

local helpers      = require("lain.helpers")
local awful        = require("awful")
local wibox        = require("wibox")
local string       = { gmatch = string.gmatch,
                       match  = string.match }
local setmetatable = setmetatable

-- PulseAudio volume
-- lain.widgets.pulseaudio

local function worker(args)
    local pulseaudio = {}
    
    local args        = args or {}
    local devicetype  = args.devicetype or "sink"
    local timeout     = args.timeout or 5
    local settings    = args.settings or function() end
    local scallback   = args.scallback
    local cmd         = args.cmd or ("pacmd list-" .. devicetype .. "s | sed -n -e '/* index:/,/index:/ !d' -e '/* index:/ p' -e '/base volume:/ d' -e '/volume:/ p' -e '/muted:/ p' -e '/device\\.string/ p'")
    
    pulseaudio.widget = wibox.widget.textbox()
    
    function pulseaudio.update()
        if scallback then cmd = scallback() end
        
        helpers.async({ awful.util.shell, "-c", cmd }, function(s)
            volume_now = {
                index = string.match(s, "index: (%S+)") or "N/A",
                device = string.match(s, "device.string = \"(%S+)\"") or "N/A",
                sink   = device,  -- legacy API
                muted  = string.match(s, "muted: (%S+)") or "N/A"
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
    
    helpers.newtimer("pulseaudio", timeout, pulseaudio.update)
    
    return pulseaudio
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
