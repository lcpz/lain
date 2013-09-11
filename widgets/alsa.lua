
--[[
                                                      
     Licensed under GNU General Public License v2     
      * (c) 2013, Luke Bonham                         
      * (c) 2010, Adrian C. <anrxc@sysphere.org>      
                                                      
--]]

local newtimer        = require("lain.helpers").newtimer

local wibox           = require("wibox")

local io              = { popen  = io.popen }
local string          = { match  = string.match }

local setmetatable    = setmetatable

-- ALSA volume
-- lain.widgets.alsa
local alsa = {}

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 5
    local channel  = args.channel or "Master"
    local settings = args.settings or function() end

    alsa.widget = wibox.widget.textbox('')

    function alsa.update()
        local f = io.popen('amixer get ' .. channel)
        local mixer = f:read("*all")
        f:close()

        volume = {}

        volume.level, volume.status = string.match(mixer, "([%d]+)%%.*%[([%l]*)")

        if volume.level == nil
        then
            volume.level  = 0
            volume.status = "off"
        end

        if volume.status == ""
        then
            if volume.level == 0
            then
                volume.status = "off"
            else
                volume.status = "on"
            end
        end

        settings()
    end

    newtimer("alsa", timeout, alsa.update)

    return setmetatable(alsa, { __index = alsa.widget })
end

return setmetatable(alsa, { __call = function(_, ...) return worker(...) end })
