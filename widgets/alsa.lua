
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
      * (c) 2010, Adrian C. <anrxc@sysphere.org>  
                                                  
--]]

local newtimer        = require("lain.helpers").newtimer
local read_pipe       = require("lain.helpers").read_pipe

local wibox           = require("wibox")

local string          = { match  = string.match,
                          format = string.format }

local setmetatable    = setmetatable

-- ALSA volume
-- lain.widgets.alsa
local alsa = {
    level  = "0",
    status = "off",
}

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 1
    local settings = args.settings or function() end

    alsa.cmd     = args.cmd or "amixer"
    alsa.channel = args.channel or "Master"

    alsa.widget = wibox.widget.textbox('')

    function alsa.update()
        local mixer = read_pipe(string.format("%s get %s", alsa.cmd, alsa.channel))

        volume_now = {}

        volume_now.level, volume_now.status = string.match(mixer, "([%d]+)%%.*%[([%l]*)")

        if volume_now.level == nil
        then
            volume_now.level  = "0"
            volume_now.status = "off"
        end

        if volume_now.status == ""
        then
            if volume_now.level == "0"
            then
                volume_now.status = "off"
            else
                volume_now.status = "on"
            end
        end

        if alsa.level ~= volume_now.level or alsa.status ~= volume_now.status
        then
            widget = alsa.widget
            settings()

            alsa.level = volume_now.level
            alsa.status = volume_now.status
        end
    end

    timer_id = string.format("alsa-%s-%s", alsa.cmd, alsa.channel)

    newtimer(timer_id, timeout, alsa.update)

    return setmetatable(alsa, { __index = alsa.widget })
end

return setmetatable(alsa, { __call = function(_, ...) return worker(...) end })
