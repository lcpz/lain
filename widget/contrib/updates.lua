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
    local updates          = { widget = wibox.widget.textbox() }
    local args            = args or {}
    local timeout         = args.timeout or 900

    local notify          = args.notify or false
    local notify_title    = args.notify_title or "Updates"
    local notify_timeout  = args.notify_timeout or 15

    local settings        = args.settings or function() end
    local package_manager = args.package_manager
    local command         = args.command or ""

    local commands = {
        pacman        = "checkupdates | sed 's/->/→/' | column -t",
        pacaur        = "pacaur -k --color never | sed 's/:: [a-zA-Z0-9]\\+ //' | sed 's/->/→/' | column -t",
        pacman_pacaur = "( checkupdates & pacaur -k --color never | sed 's/:: [a-zA-Z0-9]\\+ //' ) | sed 's/->/→/' | sort | column -t",
        dnf           = "dnf check-update --quiet",
        apt           = "apt-show-versions -u"
    }

    local update_count = 0

    function updates.update(notify)
        helpers.async({ shell, "-c", commands[package_manager] or command }, function(update_text)
            available  = tonumber((update_text:gsub('[^\n]', '')):len())
            widget = updates.widget

            if available > update_count and notify then
                updates.show_notification(update_text)
            end
            update_count = available
            settings()
        end)
    end

    function updates.automatic_update()
        -- Notify if set and update_count has increased
        updates.update(notify)
    end

    function updates.manual_update()
        -- Allways show notification
        update_count = -1
        updates.update(true)
    end

    function updates.show_notification(update_text)
        if not update_text or update_text == "" then
            update_text = "None."
        end
        naughty.notify({
            title = notify_title,
            text = string.gsub(update_text, '[\n%s]*$', ''),
            timeout = notify_timeout
        })
    end

    helpers.newtimer("updates", timeout, updates.automatic_update)

    return updates
end

return factory
