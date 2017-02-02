
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2016, Luke Bonham                     
                                                  
--]]

local helpers      = require("lain.helpers")
local awful        = require("awful")
local wibox        = require("wibox")
local string       = { gmatch = string.gmatch,
                       match  = string.match }

-- PulseAudio volume
-- lain.widgets.pulseaudio

local function factory(args)
    local pulseaudio = {}
    
    local args        = args or {}
    local devicetype  = args.devicetype or "sink"
    local timeout     = args.timeout or 5
    local scallback   = args.scallback
    
    local cmd         = args.cmd or ("pacmd list-" .. devicetype .. "s | sed -n -e '/* index:/,/index:/ !d' -e '/* index:/ p' -e '/base volume:/ d' -e '/volume:/ p' -e '/muted:/ p' -e '/device\\.string/ p'")
    -- sed script explanation:
    --  '/* index:/,/index:/ !d' removes all lines outside of the range between the line containing '* index:' and the next line containing 'index:'. '* index:' denotes the beginning of the default device section.
    --  '/* index:/ p' prints the line containing '* index:'.
    --  '/base volume:/ d' removes the line containing 'base volume:'. This is necessary due to the following script.
    --  '/volume:/ p' prints the line containing 'volume:'.
    --  '/muted:/ p' prints the line containing 'muted:'.
    --  '/device\\.string/ p' prints the line containing 'device.string:'.
    
    local settings    = args.settings or function()
            widgettext  = volume_now.left .. "%"
            tooltiptext = volume_now.left .. "% (" .. devicetype .. " " .. volume_now.index .. " \"" .. volume_now.device .. "\")"
            if volume_now.muted == "yes" then
                widgettext  = "Mute"
                tooltiptext = "Mute/" .. tooltiptext
            end
            widget:set_text(widgettext)
            tooltip:set_text(tooltiptext)
        end
    
    pulseaudio.widget = wibox.widget.textbox()
    pulseaudio.tooltip = awful.tooltip({ objects = { pulseaudio.widget } })
    
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
            tooltip = pulseaudio.tooltip
            
            settings()
        end)
    end
    
    helpers.newtimer("pulseaudio", timeout, pulseaudio.update)
    
    return pulseaudio
end

return factory
