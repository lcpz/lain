--[[

     Licensed under GNU General Public License v2
      * (c) 2017, Alphonse Mariyagnanaseelan

--]]

local helpers       = require("lain.helpers")
local awful         = require("awful")
local shell         = require("awful.util").shell
local wibox         = require("wibox")
local naughty       = require("naughty")
local lines, floor  = io.lines, math.floor
local string        = { format = string.format,
                        gsub   = string.gsub,
                        len    = string.len}

-- Available updates
-- lain.widget.contrib.updates

local function factory(args)
    local updates         = { widget = wibox.widget.textbox() }
    local args            = args or {}
    local timeout         = args.timeout or 900
    local settings        = args.settings or function() end
    local command         = args.command or ""
    local notify          = args.notify or "on"

    -- Example commands:
    -- pacman:          "checkupdates | sed 's/->/→/' | column -t",
    -- pacaur:          "pacaur -k --color never | sed 's/:: [a-zA-Z0-9]\\+ //' | sed 's/->/→/' | column -t",
    -- pacman & pacaur: "( checkupdates & pacaur -k --color never | sed 's/:: [a-zA-Z0-9]\\+ //' ) | sed 's/->/→/' | sort | column -t",
    -- dnf:             "dnf check-update --quiet",
    -- apt:             "apt-show-versions -u"
    -- pip:             "pip list --outdated --format=legacy"

    local notification_preset = args.notification_preset
    if not notification_preset then
        notification_preset = {
            title    = "Updates",
            timeout  = 15
        }
    end

    local update_count = 0

    function updates.update(notify)
        helpers.async({ shell, "-c", command }, function(update_text)
            available  = tonumber((update_text:gsub('[^\n]', '')):len())
            widget = updates.widget

            if available > update_count and notify == "on" then
                updates.show_notification(update_text)
            end
            update_count = available
            settings()
        end)
    end

    function updates.manual_update()
        -- Allways show notification
        update_count = -1
        updates.update("on")
    end

    function updates.show_notification(update_text)
        if not update_text or update_text == "" then
            notification_preset.text = "None."
        else
            notification_preset.text = string.gsub(update_text, '[\n%s]*$', '')
        end
        notification_preset.screen = scr or (updates.followtag and awful.screen.focused()) or 1

        if updates.notification then
            naughty.destroy(updates.notification)
        end
        updates.notification = naughty.notify({
            preset = notification_preset,
            timeout = notification_preset.timeout or 15
        })
    end

    helpers.newtimer("updates", timeout, function() updates.update(notify) end)

    return updates
end

return factory
