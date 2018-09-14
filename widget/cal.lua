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
local string   = string
local ipairs   = ipairs
local tconcat  = table.concat
local tonumber = tonumber
local tostring = tostring

-- Calendar notification
-- lain.widget.cal
local function factory(args)
    args = args or {}
    local cal = {
        weekStart           = args.weekStart or 2,
        attach_to           = args.attach_to or {},
        followtag           = args.followtag or false,
        icons               = args.icons or helpers.icons_dir .. "cal/white/",
        notification_preset = args.notification_preset or {
            font = "Monospace 10", fg = "#FFFFFF", bg = "#000000"
        }
    }

    function cal.hide()
        if not cal.notification then return end
        naughty.destroy(cal.notification)
        cal.notification = nil
    end

    function cal.show(timeout, month, year)
        local current_month, current_year = tonumber(os.date("%m")), tonumber(os.date("%Y"))
        local is_current_month = (not month or not year) or (month == current_month and year == current_year)
        local today = is_current_month and tonumber(os.date("%d")) -- otherwise nil and not highlighted
        local t = os.time { year = year or current_year, month = month and month+1 or current_month+1, day = 0 }
        local d = os.date("*t", t)
        local mthDays, stDay, cmonth = d.day, (d.wday-d.day-cal.weekStart+1)%7, os.date("%B %Y", t)
        local notifytable = { [1] = string.format("%s%s\n", string.rep(" ", floor((28 - cmonth:len())/2)), markup.bold(cmonth)) }
        for x = 0,6 do notifytable[#notifytable+1] = os.date("%a ", os.time { year=2006, month=1, day=x+cal.weekStart }) end
        notifytable[#notifytable] = string.format("%s\n%s", notifytable[#notifytable]:sub(1, -2), string.rep(" ", stDay*4))
        for x = 1,mthDays do
            local strx = x ~= today and x or markup.bold(markup.color(cal.notification_preset.bg, cal.notification_preset.fg, x) .. " ")
            strx = string.format("%s%s", string.rep(" ", 3 - tostring(x):len()), strx)
            notifytable[#notifytable+1] = string.format("%-4s%s", strx, (x+stDay)%7==0 and x ~= mthDays and "\n" or "")
        end

        cal.notification_preset.text = tconcat(notifytable)
        cal.hide()
        cal.notification = naughty.notify {
            preset  = cal.notification_preset,
            icon    = cal.icon,
            timeout = timeout or cal.notification_preset.timeout or 5
        }
        cal.month, cal.year = d.month, d.year
    end

    function cal.hover_on() cal.show(0) end
    function cal.hover_off() cal.hide() end
    function cal.prev()
        cal.month = cal.month - 1
        if cal.month == 0 then
            cal.month = 12
            cal.year = cal.year - 1
        end
        cal.show(0, cal.month, cal.year)
    end
    function cal.next()
        cal.month = cal.month + 1
        if cal.month == 13 then
            cal.month = 1
            cal.year = cal.year + 1
        end
        cal.show(0, cal.month, cal.year)
    end

    function cal.attach(widget)
        widget:connect_signal("mouse::enter", cal.hover_on)
        widget:connect_signal("mouse::leave", cal.hover_off)
        widget:buttons(awful.util.table.join(
                    awful.button({}, 1, cal.prev),
                    awful.button({}, 3, cal.next),
                    awful.button({}, 2, cal.hover_on),
                    awful.button({}, 5, cal.prev),
                    awful.button({}, 4, cal.next)))
    end

    for _, widget in ipairs(cal.attach_to) do cal.attach(widget) end

    return cal
end

return factory
