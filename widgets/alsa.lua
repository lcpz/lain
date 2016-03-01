
--[[

     Licensed under GNU General Public License v2
      * (c) 2013, Luke Bonham
      * (c) 2010, Adrian C. <anrxc@sysphere.org>

--]]

local newtimer        = require("lain.helpers").newtimer
local read_pipe       = require("lain.helpers").read_pipe

local awful           = require("awful")
local wibox           = require("wibox")

local string          = { match  = string.match,
                          format = string.format }

local setmetatable    = setmetatable

-- ALSA volume
-- lain.widgets.alsa
local alsa = {}

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 5
    local settings = args.settings or function() end

    alsa.cmd     = args.cmd or "amixer"
    alsa.card    = args.card or "0"
    alsa.channel = args.channel or "Master"
    alsa.step     = args.step or "2%"

    alsa.widget = wibox.widget.textbox('')

    function alsa.update()
        local mixer = read_pipe(string.format("%s -c %s get %s", alsa.cmd, alsa.card, alsa.channel))

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

        widget = alsa.widget
        settings()
    end

    alsa.widget:buttons (awful.util.table.join (
          awful.button ({}, 1, function()
            awful.util.spawn(string.format("%s -c %s set %s toggle", alsa.cmd, alsa.card, alsa.channel))
            alsa.update()
          end),
          awful.button ({}, 4, function()
            awful.util.spawn(string.format("%s -c %s set %s %s+", alsa.cmd, alsa.card, alsa.channel, alsa.step))
            alsa.update()
          end),
          awful.button ({}, 5, function()
            awful.util.spawn(string.format("%s -c %s set %s %s-", alsa.cmd, alsa.card, alsa.channel, alsa.step))
            alsa.update()
          end)
    ))

    timer_id = string.format("alsa-%s-%s", alsa.cmd, alsa.channel)

    newtimer(timer_id, timeout, alsa.update)

    return setmetatable(alsa, { __index = alsa.widget })
end

return setmetatable(alsa, { __call = function(_, ...) return worker(...) end })
