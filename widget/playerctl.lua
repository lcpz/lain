--[[

     Licensed under GNU General Public License v2
      * (c) 2018, Blade C. <dcoates@systemoverload.net>
      * (c) 2013, Luca CPZ
      * (c) 2010, Adrian C. <anrxc@sysphere.org>

--]]

local helpers  = require("lain.helpers")
local shell    = require("awful.util").shell
local escape_f = require("awful.util").escape
local focused  = require("awful.screen").focused
local naughty  = require("naughty")
local wibox    = require("wibox")
local os       = os
local string   = string

-- playerctl infos
-- lain.widget.playerctl

local function factory(args)
    local playerctl           = { widget = wibox.widget.textbox() }
    local args          = args or {}
    local timeout       = args.timeout or 2
    local cover_pattern = args.cover_pattern or "*\\.(jpg|jpeg|png|gif)$"
    local cover_size    = args.cover_size or 100
    local default_art   = args.default_art
    local notify        = "on"
    local followtag     = args.followtag or false
    local settings      = args.settings or function() end

    local metadata = string.format("playerctl metadata")
    local status = string.format("playerctl status")

    playerctl_notification_preset = { title = "Now playing", timeout = 6 }

    helpers.set_map("current playerctl track", nil)

    function playerctl.update()
        helpers.async({ shell, "-c", metadata }, function(f)
            playerctl_now = {
                artist       = "N/A",
                title        = "N/A",
                album        = "N/A",
                artUrl       = "N/A",
                rating       = "N/A",
		state        = 'N/A',
            }

            for line in string.gmatch(f, "[^\n]+") do
                for k, v in string.gmatch(line, "[%w]+%s[%w]+:([%w]+)%s+(.*)$") do
                    if     k == "title"          then playerctl_now.title       = v
                    elseif k == "artist"         then playerctl_now.artist      = v
                    elseif k == "album"          then playerctl_now.album       = escape_f(v)
                    elseif k == "artUrl"         then playerctl_now.artUrl      = escape_f(v)
                    elseif k == "rating"         then playerctl_now.rating      = escape_f(v)
                    end
                end
            end

            playerctl_notification_preset.text = string.format("Artist: %s\nAlbum: (%s)\nTitle: %s", playerctl_now.artist,
                                           playerctl_now.album, playerctl_now.title)
            widget = playerctl.widget
            settings()

            helpers.async({ shell, "-c", status }, function(playstate)
		for line in string.gmatch(playstate, "[^\n]+") do
			state = line
	        end
                

                if state == "Playing" then
                    if notify == "on" and playerctl_now.title ~= helpers.get_map("current playerctl track") then
                        helpers.set_map("current playerctl track", playerctl_now.title)

                        if followtag then playerctl_notification_preset.screen = focused() end
                        
                        local common =  {
                            preset      = playerctl_notification_preset,
                            replaces_id = playerctl.id
                        }

                        playerctl.id = naughty.notify(common).id
                    end
                elseif state ~= "Paused" then
                    helpers.set_map("current playerctl track", nil)
                end
            end)
        end)
    end

    playerctl.timer = helpers.newtimer("playerctl", timeout, playerctl.update, true, true)

    return playerctl
end

return factory
