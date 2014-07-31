
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
      * (c) 2010, Adrian C. <anrxc@sysphere.org>  
                                                  
--]]

local helpers      = require("lain.helpers")

local escape_f     = require("awful.util").escape
local awful        = require("awful")
local naughty      = require("naughty")
local wibox        = require("wibox")

local io           = { popen    = io.popen }
local os           = { execute  = os.execute,
                       getenv   = os.getenv }
local string       = { format   = string.format,
                       gmatch   = string.gmatch, }

local setmetatable = setmetatable

-- MPD infos
-- lain.widgets.mpd
local mpd = {}

local function worker(args)
    local args        = args or {}
    local timeout     = args.timeout or 2
    local password    = args.password or ""
    local host        = args.host or "127.0.0.1"
    local port        = args.port or "6600"
    local music_dir   = args.music_dir or os.getenv("HOME") .. "/Music"
    local cover_size  = args.cover_size or 100
    local default_art = args.default_art or ""
    local settings    = args.settings or function() end

    local mpdcover = helpers.scripts_dir .. "mpdcover"

    function call_mpd(command)
        local cmd  = "echo 'password " .. command .. "\nstatus\n".. command .. "\nclose'"
        local f = io.popen(cmd .. " | curl --connect-timeout 1 -fsm 3 " .. "telnet://" .. host .. ":" .. port)
        local stdout = f:lines()
        return stdout
    end
    

    mpd.widget = wibox.widget.textbox('')
    mpd.notification = nil

    mpd_notification_preset = {
        title   = "Now playing",
        timeout = 6
    }

    helpers.set_map("current mpd track", nil)

    function mpd.update()
        mpd_now = {
            state  = "N/A",
            file   = "N/A",
            artist = "N/A",
            title  = "N/A",
            album  = "N/A",
            date   = "N/A"
        }

        for line in call_mpd("currentsong") do
            for k, v in string.gmatch(line, "([%w]+):[%s](.*)$") do
                if     k == "state"  then mpd_now.state  = v
                elseif k == "file"   then mpd_now.file   = v
                elseif k == "Artist" then mpd_now.artist = escape_f(v)
                elseif k == "Title"  then mpd_now.title  = escape_f(v)
                elseif k == "Album"  then mpd_now.album  = escape_f(v)
                elseif k == "Date"   then mpd_now.date   = escape_f(v)
                end
            end
        end

        mpd_notification_preset.text = string.format("%s (%s) - %s\n%s", mpd_now.artist,
                                       mpd_now.album, mpd_now.date, mpd_now.title)
        widget = mpd.widget
        settings()

        if mpd_now.state == "play"
        then
            if mpd_now.title ~= helpers.get_map("current mpd track")
            then
                helpers.set_map("current mpd track", mpd_now.title)

                os.execute(string.format("%s %q %q %d %q", mpdcover, music_dir,
                           mpd_now.file, cover_size, default_art))

                mpd.popup()
            end
        elseif mpd_now.state ~= "pause"
        then
            helpers.set_map("current mpd track", nil)
        end
    end


    function mpd.popup()
        mpd.notification = naughty.notify({
            preset = mpd_notification_preset,
            icon = "/tmp/mpdcover.png",
            replaces_id = mpd.id,
            screen = client.focus and client.focus.screen or 1
        })
    end

    function mpd.hide()
        if mpd.notification ~= nil then
            naughty.destroy(mpd.notification)
            mpd.notification = nil
        end
    end

    mpd.widget:connect_signal("mouse::enter", function () mpd.popup() end)
    mpd.widget:connect_signal("mouse::leave", function () mpd.hide() end)

    mpd.widget:buttons(awful.util.table.join (
        awful.button ({}, 1, function()
            call_mpd("next")
            mpd.update()
        end),
        awful.button ({}, 3, function()
            call_mpd("previous")
            mpd.update()
        end)
    ))

    helpers.newtimer("mpd", timeout, mpd.update)

    return setmetatable(mpd, { __index = mpd.widget })
end

return setmetatable(mpd, { __call = function(_, ...) return worker(...) end })
