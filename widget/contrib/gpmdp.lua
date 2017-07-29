
--[[
                                                     
        Licensed under GNU General Public License v2 
        * (c) 2016, Alexandre Terrien                
                                                     
--]]

local helpers             = require("lain.helpers")
local json                = require("lain.util.dkjson")
local watch               = require("awful.widget").watch
local focused             = require("awful.screen").focused
local naughty             = require("naughty")
local next, getenv, table = next, os.getenv, table

-- Google Play Music Desktop infos
-- lain.widget.contrib.gpmdp
-- requires: curl

local function factory(args)
    local gpmdp         = {}
    local args          = args or {}
    local timeout       = args.timeout or 2
    local notify        = args.notify or "off"
    local hover         = args.hover or "off"
    local followtag     = args.followtag or false
    local file_location = args.file_location or
                          getenv("HOME") .. "/.config/Google Play Music Desktop Player/json_store/playback.json"
    local settings      = args.settings or function() end

    gpmdp_notification_preset = {
        title     = "Now playing",
        icon_size = 64,
        timeout   = 6
    }

    function gpmdp.hover_on(hover)
        local gpm_now = gpmdp.latest
        helpers.set_map("gpmdp_current", gpm_now.title)

        if followtag then gpmdp_notification_preset.screen = focused() end
        helpers.async(
            string.format("curl %s -o /tmp/gpmcover.png", gpm_now.cover_url),
            function(f)
                local old_id = nil
                if gpmdp.notification then old_id = gpmdp.notification.id end

                gpmdp.notification = naughty.notify({
                    preset = gpmdp_notification_preset,
                    icon = "/tmp/gpmcover.png",
                    replaces_id = old_id
                })
            end
        )

    end

    function gpmdp.hover_off()
        if not gpmdp.notification then return end
        naughty.destroy(gpmdp.notification)
        gpmdp.notification = nil
    end

    helpers.set_map("gpmdp_current", nil)

    local watcher = watch("pidof 'Google Play Music Desktop Player'", timeout, function(widget, stdout)
        local filelines = helpers.lines_from(file_location)
        gpm_now = { running = stdout ~= '' }

        if not next(filelines) then
            gpm_now.running = false
            gpm_now.playing = false
        else
            dict, pos, err = json.decode(table.concat(filelines), 1, nil)
            gpm_now.artist    = dict.song.artist
            gpm_now.album     = dict.song.album
            gpm_now.title     = dict.song.title
            gpm_now.cover_url = dict.song.albumArt
            gpm_now.playing   = dict.playing
        end
        gpmdp.latest = gpm_now

        gpmdp_notification_preset.text = string.format("%s (%s) - %s", gpm_now.artist, gpm_now.album, gpm_now.title)
        settings(widget)

        if gpm_now.playing then
            if notify == "on" and gpm_now.title ~= helpers.get_map("gpmdp_current") then
                gpmdp.hover_on()
            end
        elseif not gpm_now.running then
            helpers.set_map("gpmdp_current", nil)
        end
    end)

    if hover == "on" then
        watcher:connect_signal("mouse::enter", gpmdp.hover_on)
        watcher:connect_signal("mouse::leave", gpmdp.hover_off)
    end

    gpmdp.widget = watcher

    return gpmdp
end

return factory
