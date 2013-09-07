
--[[
                                                      
     Licensed under GNU General Public License v2     
      * (c) 2013,      Luke Bonham                    
      * (c) 2010-2012, Peter Hofmann                  
      * (c) 2010,      Adrian C. <anrxc@sysphere.org> 
                                                      
--]]

local markup          = require("lain.util.markup")
local run_in_terminal = require("lain.helpers").run_in_terminal

local awful           = require("awful")
local beautiful       = require("beautiful")
local wibox           = require("wibox")

local io              = io
local string          = { format = string.format,
                          match  = string.match }

local setmetatable    = setmetatable

-- ALSA volume infos
-- nain.widgets.alsa
local alsa = {
    volume = 0,
    mute = false,
}

function worker(args)
    local args = args or {}
    local channel = args.channel or "Master"
    local step = args.step or "1%"
    local header = args.header or " Vol "
    local header_color = args.header_color or beautiful.fg_normal or "#FFFFFF"
    local color = args.color or beautiful.fg_focus or "#FFFFFF"

    local myvolume = wibox.widget.textbox()
    local myvolumeupdate = function()
        local f = io.popen('amixer get ' .. channel)
        local mixer = f:read("*all")
        f:close()

        local volume, mute = string.match(mixer, "([%d]+)%%.*%[([%l]*)")

        if volume == nil
        then
            alsa.volume = 0
        else
            alsa.volume = volume
        end

        if mute == nil or mute == 'on'
        then
            alsa.mute = true
            mute = ''
        else
            alsa.mute = false
            mute = 'M'
        end

        local ret = markup(color, string.format("%d%s", volume, mute))
        myvolume:set_markup(markup(header_color, header) .. ret .. " ")
    end

    local myvolumetimer = timer({ timeout = 5 })
    myvolumetimer:connect_signal("timeout", myvolumeupdate)
    myvolumetimer:start()
    myvolumetimer:emit_signal("timeout")

    myvolume:buttons(awful.util.table.join(
        awful.button({}, 1,
            function()
                run_in_terminal('alsamixer')
             end),
        awful.button({}, 3,
            function()
                awful.util.spawn('amixer sset ' .. channel ' toggle')
            end),

        awful.button({}, 4,
            function()
                awful.util.spawn('amixer sset ' .. channel .. ' ' .. step '+')
                myvolumeupdate()
            end),

        awful.button({}, 5,
            function()
                awful.util.spawn('amixer sset ' .. channel .. ' ' .. step '-')
                myvolumeupdate()
            end)
    ))

    alsa.widget = myvolume
    alsa.channel = channel
    alsa.step = step
    alsa.notify = myvolumeupdate

    return setmetatable(alsa, { __index = alsa.widget })
end

return setmetatable(alsa, { __call = function(_, ...) return worker(...) end })
