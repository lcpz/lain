
--[[
                                                   
     Licensed under GNU General Public License v2  
      * (c) 2014, anticlockwise <http://github.com/anticlockwise>
                                                   
--]]

local helpers = require("lain.helpers")
local async   = require("lain.asyncshell")

local escape_f = require("awful.util").escape
local naughty  = require("naughty")
local wibox    = require("wibox")

local io     = { popen   = io.popen }
local os     = { execute = os.execute,
                 getenv  = os.getenv }
local string = { format  = string.format,
                 gmatch  = string.gmatch }

local setmetatable = setmetatable

local moc = {}

local function worker(args)
    local args        = args or {}
    local timeout     = args.timeout or 2
    local music_dir   = args.music_dir or os.getenv("HOME") .. "/Music"
    local cover_size  = args.cover_size or 100
    local default_art = args.default_art or ""
    local settings    = args.settings or function() end

    local mpdcover = helpers.scripts_dir .. "mpdcover"

    moc.widget = wibox.widget.textbox('')

    moc_notification_preset = {
        title   = "Now playing",
        timeout = 6
    }

    helpers.set_map("current moc track", nil)

    function moc.update()
        -- mocp -i will produce output like:
        -- Artist: Travis
        -- Album: The Man Who
        -- etc.
        async.request("mocp -i", function(f)
            moc_now = {
                state   = "N/A",
                file    = "N/A",
                artist  = "N/A",
                title   = "N/A",
                album   = "N/A",
                elapsed = "N/A",
                total   = "N/A"
            }

            for line in f:lines() do
                for k, v in string.gmatch(line, "([%w]+):[%s](.*)$") do
                    if k == "State" then moc_now.state = v
                    elseif k == "File" then moc_now.file = v
                    elseif k == "Artist" then moc_now.artist = escape_f(v)
                    elseif k == "SongTitle" then moc_now.title = escape_f(v)
                    elseif k == "Album" then moc_now.album = escape_f(v)
                    elseif k == "CurrentTime" then moc_now.elapsed = escape_f(v)
                    elseif k == "TotalTime" then moc_now.total = escape_f(v)
                    end
                end
            end

            moc_notification_preset.text = string.format("%s (%s) - %s\n%s", moc_now.artist,
                                           moc_now.album, moc_now.total, moc_now.title)
            widget = moc.widget
            settings()

            if moc_now.state == "PLAY" then
                if moc_now.title ~= helpers.get_map("current moc track") then
                    helpers.set_map("current moc track", moc_now.title)
                    os.execute(string.format("%s %q %q %d %q", mpdcover, "",
                               moc_now.file, cover_size, default_art))

                    moc.id = naughty.notify({
                        preset = moc_notification_preset,
                        icon = "/tmp/mpdcover.png",
                        replaces_id = moc.id,
                    }).id
                end
            elseif  moc_now.state ~= "PAUSE" then
                helpers.set_map("current moc track", nil)
            end
        end)
    end

    helpers.newtimer("moc", timeout, moc.update)

    return setmetatable(moc, { __index = moc.widget })
end

return setmetatable(moc, { __call = function(_, ...) return worker(...) end })
