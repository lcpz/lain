--[[

     Licensed under GNU General Public License v2
      * (c) 2013,      Luca CPZ
      * (c) 2010-2012, Peter Hofmann

--]]

local helpers  = require("lain.helpers")
local wibox    = require("wibox")
local awful    = require("awful")
local naughty  = require("naughty")

-- Wireless Quality link (converted to percentages) and wireless status
-- Requires `iw`
-- lain.widget.wirelessStatus

local function factory(args)
    local args     = args or {}

    local wirelessStatus = {
        widget = args.widget or wibox.widget.imagebox(),
        pressed   = args.pressed or function(button) end
    }
    local timeout   = args.timeout or 2
    local followtag = args.followtag or false
    local notification_preset = args.notification_preset or {}
    local settings  = args.settings or function() end
    local showpopup = args.showpopup or "on"  -- Show notification popup while hovering above widget

    wirelessStatus_now = {
        interface = "",
        perc = 0,
        status = "",
        notification_text = "No connection"
    }

    -- Reset to default values
    function wirelessStatus.reset()
        wirelessStatus_now.interface = ""
        wirelessStatus_now.perc = 0
        wirelessStatus_now.status = ""
        wirelessStatus_now.notification_text = "No connection"
    end

    -- Show notification popup
    function wirelessStatus.show(seconds)
        wirelessStatus.hide()

        if followtag then
            notification_preset.screen = focused()
        end

        if wirelessStatus_now.notification_text == "" then
            wirelessStatus.update()
        end

        wirelessStatus.notification = naughty.notify {
            preset  = notification_preset,
            text    = wirelessStatus_now.notification_text,
            timeout = type(seconds) == "number" and seconds or notification_preset.timeout
        }
    end

    -- Hide notification popup
    function wirelessStatus.hide()
        if wirelessStatus.notification then
            naughty.destroy(wirelessStatus.notification)
            wirelessStatus.notification = nil
        end
    end

    function wirelessStatus.attach(obj)
        obj:connect_signal("mouse::enter", function()
            wirelessStatus.show(0)
        end)
        obj:connect_signal("mouse::leave", function()
            wirelessStatus.hide()
        end)
    end

    -- Get name of wireless interface
    function wirelessStatus.getInterface()
        helpers.async_with_shell(
            "awk 'NR==3 {printf(\"%s\\n\", $1)}' /proc/net/wireless",
            function(stdout, exit_code)
                -- Store interface name
                -- Remove last character/s from string ("wlp4s0:"" -> "wlp4s0")
                wirelessStatus_now.interface = stdout:sub(0, -3)
            end
        )
    end

    function wirelessStatus.update()
        -- Get status and Quality link (convert quality link to percentages)
        helpers.async_with_shell("awk 'NR==3 {printf(\"%d-%.0f\\n\", $2, $3*10/7)}' /proc/net/wireless", function(stdout, exit_code)
            if stdout == "" then
                -- No output from command above -> reset internal values to default
                wirelessStatus.reset()
            else
                -- Status and Quality link received
                local status, perc = stdout:match("(%d)-(%d+)")
                perc = tonumber(perc)
                wirelessStatus_now.perc = perc
                wirelessStatus_now.status = status

                if  wirelessStatus_now.interface == "" then
                    -- Get interface name
                    wirelessStatus.getInterface()
                end

                -- Get information about active connection
                local cmd_getInfo = "iw dev "..wirelessStatus_now.interface.." link"
                helpers.async_with_shell(cmd_getInfo, function(stdout, exit_code)
                    wirelessStatus_now.notification_text = stdout
                end)
            end
        end)

        widget = wirelessStatus.widget
        settings()
    end

    -- Show notification popup while hovering above widget
    if showpopup == "on" then wirelessStatus.attach(wirelessStatus.widget) end

    wirelessStatus.widget:connect_signal("button::press", function(c, _, _, button)
        wirelessStatus.pressed(button)
    end)

    helpers.newtimer("wirelessStatus", timeout, wirelessStatus.update)

    return wirelessStatus
end

return factory
