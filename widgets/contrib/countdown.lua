
--[[

     Licensed under GNU General Public License v2
      * (c) 2016, Gergely Peidl

--]]

local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local newtimer = require("lain.helpers").newtimer
local setmetatable = setmetatable
local countdown = {}

-- Countdown with notification
-- lain.widgets.contrib.countdown


-- Get remaining seconds
-- @param offset: number of secunds + now
local function get_remaining_time(offset)
    local remaining = offset - os.time()

    -- Show a notification when timer is up
    if remaining == 0 then
        naughty.notify({
            title = "Countdown has finished!"
        })
    end

    return remaining
end

-- Set countdown seconds
-- @param mypromtbox: promtbox
function countdown:set_countdown(mypromptbox)
    awful.prompt.run({ prompt = "Countdown minutes: " }, mypromptbox[mouse.screen].widget,
        function(input)
            if input:len() > 0 and tonumber(input) ~= nil then
                countdown.secounds = os.time() + math.floor(tonumber(input) * 60)
            end
        end)
end

local function worker(args)
    local args = args or {}
    local timeout = args.timeout or 1
    local settings = args.settings or function() end

    countdown.widget = wibox.widget.textbox('')

    function update()
        if (countdown.secounds ~= nil) then
            remaining = get_remaining_time(countdown.secounds)
            widget = countdown.widget
            settings()
        end
    end

    newtimer("countdown", timeout, update)

    return countdown.widget
end

return setmetatable(countdown, { __call = function(_, ...) return worker(...) end })