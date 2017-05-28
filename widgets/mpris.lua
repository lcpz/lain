
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2016, 2009                            
                                                  
--]]

local helpers      = require("lain.helpers")
local read_pipe    = require("lain.helpers").read_pipe

local escape_f     = require("awful.util").escape
local wibox        = require("wibox")

local setmetatable = setmetatable

-- MPRIS info
-- lain.widgets.mpris
local mpris = {}

local function worker(args)
    local args        = args or {}
    local timeout     = args.timeout or 2
    local settings    = args.settings or function() end

    mpris.widget = wibox.widget.textbox('')

    function mpris.update()

        mpris_now = {
            state        = "N/A",
            artist       = "N/A",
            title        = "N/A",
            art_url      = "N/A",
            album        = "N/A",
            album_artist = "N/A",
        }

        local status = read_pipe("playerctl status"):gsub("\n*$", "")

        -- Turn playerctl status into something a little more usable
        if     status == "Playing" then mpris_now.state = "play"
        elseif status == "Paused"  then mpris_now.state = "pause"
        else mpris_now.state = "not_found"
        end

        local metadata = read_pipe("playerctl metadata")

        for k, v in string.gmatch(metadata, "'[^:]+:([^']+)':[%s]<%[?'([^']+)'%]?>") do
            if     k == "artUrl"         then mpris_now.art_url      = v
            elseif k == "artist"         then mpris_now.artist       = escape_f(v)
            elseif k == "title"          then mpris_now.title        = escape_f(v)
            elseif k == "album"          then mpris_now.album        = escape_f(v)
            elseif k == "albumArtist"    then mpris_now.album_artist = escape_f(v)
            end
        end

        widget = mpris.widget
        settings()

    end

    helpers.newtimer("mpris", timeout, mpris.update)

    return setmetatable(mpris, { __index = mpris.widget })
end

return setmetatable(mpris, { __call = function(_, ...) return worker(...) end })
