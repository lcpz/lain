--[[

     Licensed under GNU General Public License v2
      * (c) 2013,      Luca CPZ
      * (c) 2010-2012, Peter Hofmann

--]]

local helpers  = require("lain.helpers")
local wibox    = require("wibox")
local naughty  = require("naughty")

-- Microphone state
-- lain.widget.mic

local function factory(args)
    local args     = args or {}

    local mic      = { widget = args.widget or wibox.widget.imagebox() }
    local timeout  = args.timeout or 2
    local settings = args.settings or function() end

    mic_now = {
        state = "unmute"
    }

    function mic.update()
        local current_micState = "error"

        -- Read `amixer get Capture` command and try to `grep` all "[on]" lines.
        --   - If there are lines with "[on]" then assume microphone is "unmuted".
        --   - If there are NO lines with "[on]" then assume microphone is "muted".
        helpers.async_with_shell("amixer get Capture | grep '\\[on\\]'", function(stdout, exit_code)
            if exit_code == 1 then
                -- Exit code 1 - no line selected
                current_micState = "muted"
            elseif exit_code == 0 then
                -- Exit code 0 - a line is selected
                current_micState = "unmuted"
            else
                -- Other exit code (2) - error occurred
                current_micState = "error"
            end

            -- Compare new and old state
            if current_micState ~= mic_now.state then
                if current_micState == "muted" then
                    naughty.notify({preset=naughty.config.presets.normal, title="mic widget info", text='muted'})
                elseif current_micState == "unmuted" then
                    naughty.notify({preset=naughty.config.presets.normal, title="mic widget info", text='unmuted'})
                else
                    naughty.notify({preset=naughty.config.presets.critical, title="mic widget error", text='Error on "amixer get Capture | grep \'\\[on\\]\'"'})
                end

                -- Store new microphone state
                mic_now.state = current_micState
            end
        end)

        widget = mic.widget
        settings()
    end

    helpers.newtimer("mic", timeout, mic.update)

    return mic
end

return factory
