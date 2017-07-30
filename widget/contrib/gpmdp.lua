
--[[
                                                     
        Licensed under GNU General Public License v2 
        * (c) 2016, Alexandre Terrien                
                                                     
--]]

local naughty = require("naughty")

-- Google Play Music Desktop infos
-- lain.widget.contrib.gpmdp
-- requires: curl

local gpmdp = {
    notify        = "on",
    followtag     = false,
    file_location = os.getenv("HOME") .. "/.config/Google Play Music Desktop Player/json_store/playback.json",
    notification_preset = {
        title     = "Now playing",
        icon_size = dpi(128),
        timeout   = 6
    },
    notification  = nil,
    current_track = nil,
}

function gpmdp.notification_on()
    local gpm_now = gpmdp.latest
    gpmdp.current_track = gpm_now.title

    if gpmdp.followtag then gpmdp.notification_preset.screen = awful.screen.focused() end
    awful.spawn.easy_async(string.format("curl %s -o /tmp/gpmcover.png", gpm_now.cover_url), function(stdout)
        local old_id = nil
        if gpmdp.notification then old_id = gpmdp.notification.id end

        gpmdp.notification = naughty.notify({
            preset = gpmdp.notification_preset,
            icon = "/tmp/gpmcover.png",
            replaces_id = old_id
        })
    end)
end

function gpmdp.notification_off()
    if not gpmdp.notification then return end
    naughty.destroy(gpmdp.notification)
    gpmdp.notification = nil
end

function gpmdp.get_lines(file)
    local f = io.open(file)
    if not f then
        return
    else
        f:close()
    end

    local lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end
    return lines
end

gpmdp.widget = awful.widget.watch("pidof 'Google Play Music Desktop Player'", 2, function(widget, stdout)
    local filelines = gpmdp.get_lines(gpmdp.file_location)
    if not filelines then return end -- GPMDP not running?

    gpm_now = { running = stdout ~= '' }

    if not next(filelines) then
        gpm_now.running = false
        gpm_now.playing = false
    else
        dict, pos, err    = require('dkjson').decode(table.concat(filelines), 1, nil)
        gpm_now.artist    = dict.song.artist
        gpm_now.album     = dict.song.album
        gpm_now.title     = dict.song.title
        gpm_now.cover_url = dict.song.albumArt
        gpm_now.playing   = dict.playing
    end
    gpmdp.latest = gpm_now

    -- customize here
    gpmdp_notification_preset.text = string.format("%s (%s) - %s", gpm_now.artist, gpm_now.album, gpm_now.title)
    widget:set_text(gpm_now.artist .. " - " .. gpm_now.title)

    if gpm_now.playing then
        if gpmdp.notify == "on" and gpm_now.title ~= gpmdp.current_track then
            gpmdp.notification_on()
        end
    elseif not gpm_now.running then
        gpmdp.current_track = nil
    end
end)

-- add mouse hover
gpmdp.widget:connect_signal("mouse::enter", gpmdp.notification_on)
gpmdp.widget:connect_signal("mouse::leave", gpmdp.notification_off)

return gpmdp
