--[[

     Licensed under GNU General Public License v2
      * (c) 2018, Luca CPZ

--]]

local helpers  = require("lain.helpers")
local markup   = require("lain.util.markup")
local awful    = require("awful")
local naughty  = require("naughty")
local floor    = math.floor
local os       = os
local pairs    = pairs
local string   = string
local tconcat  = table.concat
local tonumber = tonumber
local tostring = tostring

-- Calendar notification
-- lain.widget.cal

local function factory(args)
    args = args or {}
    local cal = {
        attach_to           = args.attach_to or {},
        week_start          = args.week_start or 2,
        three               = args.three or false,
        followtag           = args.followtag or false,
        icons               = args.icons or helpers.icons_dir .. "cal/white/",
        notification_preset = args.notification_preset or {
            font = "Monospace 10", fg = "#FFFFFF", bg = "#000000"
        }
    }

    function cal.build(month, year)
        local current_month, current_year = tonumber(os.date("%m")), tonumber(os.date("%Y"))
        local is_current_month = (not month or not year) or (month == current_month and year == current_year)
        local today = is_current_month and tonumber(os.date("%d")) -- otherwise nil and not highlighted
        local t = os.time { year = year or current_year, month = month and month+1 or current_month+1, day = 0 }
        local d = os.date("*t", t)
        local mth_days, st_day, this_month = d.day, (d.wday-d.day-cal.week_start+1)%7, os.date("%B %Y", t)
        local notifytable = { [1] = string.format("%s%s\n", string.rep(" ", floor((28 - this_month:len())/2)), markup.bold(this_month)) }
        for x = 0,6 do notifytable[#notifytable+1] = os.date("%a ", os.time { year=2006, month=1, day=x+cal.week_start }) end
        notifytable[#notifytable] = string.format("%s\n%s", notifytable[#notifytable]:sub(1, -2), string.rep(" ", st_day*4))
        for x = 1,mth_days do
            local strx = x ~= today and x or markup.bold(markup.color(cal.notification_preset.bg, cal.notification_preset.fg, x) .. " ")
            strx = string.format("%s%s", string.rep(" ", 3 - tostring(x):len()), strx)
            notifytable[#notifytable+1] = string.format("%-4s%s", strx, (x+st_day)%7==0 and x ~= mth_days and "\n" or "")
        end
        if string.len(cal.icons or "") > 0 and today then cal.icon = cal.icons .. today .. ".png" end
        cal.month, cal.year = d.month, d.year
        return notifytable
    end

    function cal.getdate(month, year, offset)
        if not month or not year then
            month = tonumber(os.date("%m"))
            year  = tonumber(os.date("%Y"))
        end

        month = month + offset

        while month > 12 do
            month = month - 12
            year = year + 1
        end

        while month < 1 do
            month = month + 12
            year = year - 1
        end

        return month, year
    end

    function cal.hide()
        if not cal.notification then return end
        naughty.destroy(cal.notification)
        cal.notification = nil
    end

    function cal.show(timeout, month, year, scr)
        cal.notification_preset.text = tconcat(cal.build(month, year))

        if cal.three then
            local current_month, current_year = cal.month, cal.year
            local prev_month, prev_year = cal.getdate(cal.month, cal.year, -1)
            local next_month, next_year = cal.getdate(cal.month, cal.year,  1)
            cal.notification_preset.text = string.format("%s\n\n%s\n\n%s",
            tconcat(cal.build(prev_month, prev_year)), cal.notification_preset.text,
            tconcat(cal.build(next_month, next_year)))
            cal.month, cal.year = current_month, current_year
        end

        cal.hide()
        cal.notification = naughty.notify {
            preset  = cal.notification_preset,
            screen  = cal.followtag and awful.screen.focused() or scr or 1,
            icon    = cal.icon,
            timeout = timeout or cal.notification_preset.timeout or 5
        }
    end

    function cal.hover_on() cal.show(0) end
    function cal.move(offset)
        local offset = offset or 0
        cal.month, cal.year = cal.getdate(cal.month, cal.year, offset)
        cal.show(0, cal.month, cal.year)
    end
    function cal.prev() cal.move(-1) end
    function cal.next() cal.move( 1) end

    function cal.attach(widget)
        widget:connect_signal("mouse::enter", cal.hover_on)
        widget:connect_signal("mouse::leave", cal.hide)
        widget:buttons(awful.util.table.join(
                    awful.button({}, 1, cal.prev),
                    awful.button({}, 3, cal.next),
                    awful.button({}, 2, cal.hover_on),
                    awful.button({}, 5, cal.prev),
                    awful.button({}, 4, cal.next)))
    end

    for _, widget in pairs(cal.attach_to) do cal.attach(widget) end

    return cal
end

return factory
