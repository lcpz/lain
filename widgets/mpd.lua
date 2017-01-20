
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
      * (c) 2010, Adrian C. <anrxc@sysphere.org>  
                                                  
--]]

local helpers      = require("lain.helpers")

local shell        = require("awful.util").shell
local escape_f     = require("awful.util").escape
local focused      = require("awful.screen").focused
local naughty      = require("naughty")
local wibox        = require("wibox")

local os           = { getenv = os.getenv }
local string       = { format = string.format,
                       gmatch = string.gmatch,
                       match  = string.match }

local setmetatable = setmetatable

-- MPD infos
-- lain.widgets.mpd
local mpd = helpers.make_widget_textbox()

local function worker(args)
    local args          = args or {}
    local timeout       = args.timeout or 2
    local password      = (args.password and #args.password > 0 and string.format("password %s\\n", args.password)) or ""
    local host          = args.host or "127.0.0.1"
    local port          = args.port or "6600"
    local music_dir     = args.music_dir or os.getenv("HOME") .. "/Music"
    local cover_pattern = args.cover_pattern or "*\\.(jpg|jpeg|png|gif)$"
    local cover_size    = args.cover_size or 100
    local default_art   = args.default_art or ""
    local notify        = args.notify or "on"
    local followtag     = args.followtag or false
    local settings      = args.settings or function() end

    local mpdh = string.format("telnet://%s:%s", host, port)
    local echo = string.format("printf \"%sstatus\\ncurrentsong\\nclose\\n\"", password)
    local cmd  = string.format("%s -c '%s | curl --connect-timeout 1 -fsm 3 %s'", shell, echo, mpdh)

    mpd_notification_preset = { title = "Now playing", timeout = 6 }

    helpers.set_map("current mpd track", nil)

    function mpd.update()
        helpers.async(cmd, function(f)
            mpd_now = {
                random_mode  = false,
                single_mode  = false,
                repeat_mode  = false,
                consume_mode = false,
                pls_pos      = "N/A",
                pls_len      = "N/A",
                state        = "N/A",
                file         = "N/A",
                name         = "N/A",
                artist       = "N/A",
                title        = "N/A",
                album        = "N/A",
                genre        = "N/A",
                track        = "N/A",
                date         = "N/A",
                time         = "N/A",
                elapsed      = "N/A"
            }

            for line in string.gmatch(f, "[^\n]+") do
                for k, v in string.gmatch(line, "([%w]+):[%s](.*)$") do
                    if     k == "state"          then mpd_now.state        = v
                    elseif k == "file"           then mpd_now.file         = v
                    elseif k == "Name"           then mpd_now.name         = escape_f(v)
                    elseif k == "Artist"         then mpd_now.artist       = escape_f(v)
                    elseif k == "Title"          then mpd_now.title        = escape_f(v)
                    elseif k == "Album"          then mpd_now.album        = escape_f(v)
                    elseif k == "Genre"          then mpd_now.genre        = escape_f(v)
                    elseif k == "Track"          then mpd_now.track        = escape_f(v)
                    elseif k == "Date"           then mpd_now.date         = escape_f(v)
                    elseif k == "Time"           then mpd_now.time         = v
                    elseif k == "elapsed"        then mpd_now.elapsed      = string.match(v, "%d+")
                    elseif k == "song"           then mpd_now.pls_pos      = v
                    elseif k == "playlistlength" then mpd_now.pls_len      = v
                    elseif k == "repeat"         then mpd_now.repeat_mode  = v ~= "0"
                    elseif k == "single"         then mpd_now.single_mode  = v ~= "0"
                    elseif k == "random"         then mpd_now.random_mode  = v ~= "0"
                    elseif k == "consume"        then mpd_now.consume_mode = v ~= "0"
                    end
                end
            end

            mpd_notification_preset.text = string.format("%s (%s) - %s\n%s", mpd_now.artist,
                                           mpd_now.album, mpd_now.date, mpd_now.title)
            widget = mpd.widget
            settings()

            if mpd_now.state == "play" then
                if notify == "on" and mpd_now.title ~= helpers.get_map("current mpd track") then
                    helpers.set_map("current mpd track", mpd_now.title)

                    if followtag then mpd_notification_preset.screen = focused() end

                    local common =  {
                        preset      = mpd_notification_preset,
                        icon        = default_art,
                        icon_size   = cover_size,
                        replaces_id = mpd.id,
                    }

                    if not string.match(mpd_now.file, "http.*://") then -- local file instead of http stream
                        local path   = string.format("%s/%s", music_dir, string.match(mpd_now.file, ".*/"))
                        local cover  = string.format("%s -c \"find '%s' -maxdepth 1 -type f | egrep -i -m1 '%s'\"", shell, path, cover_pattern)
                        helpers.async(cover, function(current_icon)
                            common.icon = current_icon:gsub("\n", "")
                            mpd.id = naughty.notify(common).id
                        end)
                    else
                        mpd.id = naughty.notify(common).id
                    end

                end
            elseif mpd_now.state ~= "pause" then
                helpers.set_map("current mpd track", nil)
            end
        end)
    end

    helpers.newtimer("mpd", timeout, mpd.update)

    return mpd
end

return setmetatable(mpd, { __call = function(_, ...) return worker(...) end })
