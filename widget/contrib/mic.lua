--[[

     Licensed under GNU General Public License v2
      * (c) 2021,      bzgec
      * (c) 2013,      Luca CPZ
      * (c) 2010-2012, Peter Hofmann

--]]

local wibox    = require("wibox")
local naughty  = require("naughty")
local awful    = require("awful")
local gears    = require("gears")

-- Microphone state
-- Requirements:
--   - `amixer`
-- Usage:
--   - `theme.lua`:
--     ```lua
--     theme.mic = lain.widget.contrib.mic({
--         timeout = 10,
--         settings = function(self)
--             if self.state == "muted" then
--                 self.widget:set_image(theme.widget_micMuted)
--             else
--                 self.widget:set_image(theme.widget_micUnmuted)
--             end
--         end
--     })
--     ```
--   - `rc.lua`:
--     ```lua
--     -- Toggle microphone state
--     awful.key({ modkey, "Shift" }, "m",
--               function ()
--                   os.execute("amixer set Capture toggle")
--                   --lain.widget.mic.update()
--                   beautiful.mic:update()
--               end,
--               {description = "Toggle microphone (amixer)", group = "Hotkeys"}
--     ),
--     ```

local function factory(args)
    local args     = args or {}

    local mic      = {
        widget = args.widget or wibox.widget.imagebox(),
        settings = args.settings or function(self) end,
        timeout  = args.timeout or 10,
        timer = gears.timer,
        state = "unmute",
    }

    function mic.pressed(self, button)
        if button == 1 then
            awful.spawn.easy_async_with_shell("amixer set Capture toggle")
            self:update()
        end
    end

    function mic.update(self)
        self.timer:emit_signal("timeout")
    end

    -- Read `amixer get Capture` command and try to `grep` all "[on]" lines.
    --   - If there are lines with "[on]" then assume microphone is "unmuted".
    --   - If there are NO lines with "[on]" then assume microphone is "muted".
    mic, mic.timer = awful.widget.watch(
        "bash -c \"amixer get Capture | grep '\\[on\\]'\"",
        mic.timeout,
        function(self, stdout, stderr, exitreason, exitcode)
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
            if current_micState ~= self.state then
                if current_micState == "muted" then
                    naughty.notify({preset=naughty.config.presets.normal, title="mic widget info", text='muted'})
                elseif current_micState == "unmuted" then
                    naughty.notify({preset=naughty.config.presets.normal, title="mic widget info", text='unmuted'})
                else
                    naughty.notify({preset=naughty.config.presets.critical, title="mic widget error", text='Error on "amixer get Capture | grep \'\\[on\\]\'"'})
                end

                -- Store new microphone state
                self.state = current_micState
            end

            -- Call user/theme defined function
            self:settings()
        end,
        mic  -- base_widget (passed in callback function as first parameter)
    )

    mic.widget:connect_signal("button::press", function(c, _, _, button)
        mic:pressed(button)
    end)

    return mic
end

return factory
