
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
      * (c) 2010, Adrian C. <anrxc@sysphere.org>  
                                                  
--]]

local helpers      = require("lain.helpers")
local read_pipe    = require("lain.helpers").read_pipe

local wibox        = require("wibox")

local string       = { match  = string.match,
                       format = string.format }

local setmetatable = setmetatable

-- ALSA volume
-- lain.widgets.alsa
local alsa = helpers.make_widget_textbox()

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 5
    local settings = args.settings or function() end

    alsa.cmd           = args.cmd or "amixer"
    alsa.channel       = args.channel or "Master"
    alsa.togglechannel = args.togglechannel
    alsa.last_level    = "0"
    alsa.last_status   = ""

    function alsa.update()
        mixer = read_pipe(string.format("%s get %s", alsa.cmd, alsa.channel))
        l, s  = string.match(mixer, "([%d]+)%%.*%[([%l]*)")

        -- HDMIs can have a channel different from Master for toggling mute
        if alsa.togglechannel then
            s = string.match(read_pipe(string.format("%s get %s", alsa.cmd, alsa.togglechannel)), "%[(%a+)%]")
        end

        if alsa.last_level ~= l or alsa.last_status ~= s then
            volume_now = { level = l, status = s }
            alsa.last_level  = l
            alsa.last_status = s

            widget = alsa.widget
            settings()
        end
    end

    timer_id = string.format("alsa-%s-%s", alsa.cmd, alsa.channel)
    helpers.newtimer(timer_id, timeout, alsa.update)

    return alsa
end

return setmetatable(alsa, { __call = function(_, ...) return worker(...) end })
