
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
                                                  
--]]

local helpers      = require("lain.helpers")
local markup       = require("lain.util.markup")
local awful        = require("awful")
local naughty      = require("naughty")
local os           = { date   = os.date }
local string       = { format = string.format,
                       gsub   = string.gsub }
local ipairs       = ipairs
local tonumber     = tonumber
local setmetatable = setmetatable

-- Calendar notification
-- lain.widgets.calendar
local calendar = { offset = 0 }

function calendar.hide()
    naughty.destroy(naughty.getById(calendar.id))
end

function calendar.show(t_out, inc_offset, scr)
    local today = os.date("%d")
    local offs = inc_offset or 0
    local f

    calendar.offset = calendar.offset + offs

    local current_month = (offs == 0 or calendar.offset == 0)

    if current_month then -- today highlighted
        calendar.offset = 0
        calendar.notify_icon = string.format("%s%s.png", calendar.icons, today)
        f = calendar.cal
    else -- no current month showing, no day to highlight
       local month = tonumber(os.date("%m"))
       local year  = tonumber(os.date("%Y"))

       month = month + calendar.offset

       while month > 12 do
           month = month - 12
           year = year + 1
       end

       while month < 1 do
           month = month + 12
           year = year - 1
       end

       calendar.notify_icon = nil
       f = string.format("%s %s %s", calendar.cal, month, year)
    end

    if calendar.followtag then
        calendar.notification_preset.screen = awful.screen.focused()
    else
        calendar.notification_preset.screen = src or 1
    end

    helpers.async(f, function(ws)
        fg, bg = calendar.notification_preset.fg, calendar.notification_preset.bg
        ws = ws:gsub("%c%[%d+[m]?%d+%c%[%d+[m]?", markup.bold(markup.color(bg, fg, today)))
        calendar.hide()
        calendar.id = naughty.notify({
            replaces_id = calendar.id,
            preset      = calendar.notification_preset,
            text        = ws:gsub("\n*$", ""),
            icon        = calendar.notify_icon,
            timeout     = t_out or calendar.notification.preset.timeout or 5
        }).id
    end)
end

function calendar.attach(widget)
    widget:connect_signal("mouse::enter", function () calendar.show(0) end)
    widget:connect_signal("mouse::leave", function () calendar.hide() end)
    widget:buttons(awful.util.table.join(awful.button({ }, 1, function ()
                                             calendar.show(0, -1, calendar.scr_pos) end),
                                         awful.button({ }, 3, function ()
                                             calendar.show(0, 1, calendar.scr_pos) end),
                                         awful.button({ }, 4, function ()
                                             calendar.show(0, -1, calendar.scr_pos) end),
                                         awful.button({ }, 5, function ()
                                             calendar.show(0, 1, calendar.scr_pos) end)))
end

local function worker(args)
    local args                   = args or {}
    calendar.cal                 = args.cal or "/usr/bin/cal --color=always"
    calendar.attach_to           = args.attach_to or {}
    calendar.followtag           = args.followtag or false
    calendar.icons               = args.icons or helpers.icons_dir .. "cal/white/"
    calendar.notification_preset = args.notification_preset

    if not calendar.notification_preset then
        calendar.notification_preset = {
            font = "Monospace 10",
            fg   = "#FFFFFF",
            bg   = "#000000"
        }
    end

    for i, widget in ipairs(calendar.attach_to) do calendar.attach(widget) end
end

return setmetatable(calendar, { __call = function(_, ...) return worker(...) end })
