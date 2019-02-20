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
        week_number         = args.week_number or false,
        week_number_format  = args.week_number_format or args.week_number_left and "%3d | " or " | %-3d",
        week_number_left    = args.week_number_left or false,
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

        if cal.week_number then
            local m = os.time { year = year or current_year, month = month and month or current_month, day = 0 }
            local head_prepend = string.rep(" ", tostring(string.format(cal.week_number_format, 0)):len())
            local week_number = function(x) return string.format(cal.week_number_format, os.date("%V", m) + (x ~=0 and floor((x+st_day)/7) - 1 or 0)) end
            local mod_days = function(x) return (x+st_day)%7 end

            if cal.week_number_left then
                notifytable[1] = head_prepend .. notifytable[1]                             -- month-year row
                notifytable[2] = head_prepend .. notifytable[2]                             -- weekdays row
                notifytable[8] = notifytable[8]:gsub("\n", "\n" .. week_number(0))          -- first week of the month

                for x=10, #notifytable do
                    if mod_days(x)==2 then
                        notifytable[x]=week_number(x) .. notifytable[x]
                    end
                end
            else
                notifytable[8] = notifytable[8]:gsub("\n", head_prepend .. "\n")            -- weekdays row
                for x=9, #notifytable do
                    if mod_days(x)==1 then
                        notifytable[x]=notifytable[x]:gsub("\n", week_number(x-7) .. "\n")
                    end
                end
                -- last week of the month
                local end_days = mod_days(mth_days)==0 and 0 or 7-mod_days(mth_days)
                notifytable[#notifytable] = notifytable[#notifytable] .. string.rep(" ", 4*end_days) .. week_number(mth_days + end_days)
            end
        end

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
