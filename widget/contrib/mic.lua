--[[

     Licensed under GNU General Public License v2
      * (c) 2013,      Luca CPZ
      * (c) 2010-2012, Peter Hofmann

--]]

local helpers  = require("lain.helpers")
local wibox    = require("wibox")
local naughty  = require("naughty")
local awful    = require("awful")
local gears    = require("gears")

-- Microphone state
-- lain.widget.mic

local function factory(args)
    local args     = args or {}

    local timeout  = args.timeout or 10
    local settings = args.settings or function() end
    local mic      = {
        widget_imageBox = wibox.widget.imagebox(),
        timer = gears.timer,
        state = "unmute",
    }

    function mic.pressed(button)
        if button == 1 then
            helpers.async("amixer set Capture toggle")
            mic.update()
        end
    end

    function mic.update()
        mic.timer:emit_signal("timeout")
    end

    -- Read `amixer get Capture` command and try to `grep` all "[on]" lines.
    --   - If there are lines with "[on]" then assume microphone is "unmuted".
    --   - If there are NO lines with "[on]" then assume microphone is "muted".
    mic, mic.timer = awful.widget.watch(
        "bash -c \"amixer get Capture | grep '\\[on\\]'\"",
        timeout,
        function(widget, stdout, stderr, exitreason, exitcode)
            local current_micState = "error"

            if exitcode == 1 then
                -- Exit code 1 - no line selected
                current_micState = "muted"
            elseif exitcode == 0 then
                -- Exit code 0 - a line is selected
                current_micState = "unmuted"
            else
                -- Other exit code (2) - error occurred
                current_micState = "error"
            end

            -- Compare new and old state
            if current_micState ~= widget.state then
                if current_micState == "muted" then
                    naughty.notify({preset=naughty.config.presets.normal, title="mic widget info", text='muted'})
                elseif current_micState == "unmuted" then
                    naughty.notify({preset=naughty.config.presets.normal, title="mic widget info", text='unmuted'})
                else
                    naughty.notify({preset=naughty.config.presets.critical, title="mic widget error", text='Error on "amixer get Capture | grep \'\\[on\\]\'"'})
                end

                -- Store new microphone state
                widget.state = current_micState
            end

            -- Call user/theme defined function
            settings()
        end,
        mic
    )

    mic.widget_imageBox:connect_signal("button::press", function(c, _, _, button)
        mic.pressed(button)
    end)

    return mic
end

return factory
