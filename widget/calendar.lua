--[[

     Licensed under GNU General Public License v2
      * (c) 2013, Luca CPZ

--]]

local helpers      = require("lain.helpers")
local markup       = require("lain.util.markup")
local awful        = require("awful")
local naughty      = require("naughty")
local mouse        = mouse
local os           = { date   = os.date }
local string       = { format = string.format,
                       gsub   = string.gsub }
local ipairs       = ipairs
local tonumber     = tonumber
local setmetatable = setmetatable

-- Calendar notification
-- lain.widget.calendar
local calendar = { offset = 0 }

function calendar.hide()
    if not calendar.notification then return end
    naughty.destroy(calendar.notification)
    calendar.notification = nil
end

function calendar.show(t_out, inc_offset, scr)
    local f, offs = nil, inc_offset or 0

    calendar.notification_preset.screen = scr or (calendar.followtag and awful.screen.focused()) or 1
    calendar.offset = calendar.offset + offs

    local current_month = (offs == 0 or calendar.offset == 0)

    if current_month then -- today highlighted
        calendar.offset = 0
        calendar.icon   = calendar.icons:len() > 0 and string.format("%s%s.png", calendar.icons, tonumber(os.date("%d")))
        f               = calendar.cal
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

       calendar.icon = nil
       f = string.format("%s %s %s", calendar.cal, month, year)
    end

    helpers.async(f, function(ws)
        local fg, bg = calendar.notification_preset.fg, calendar.notification_preset.bg
        calendar.notification_preset.text = ws:gsub("%c%[%d+[m]?%s?%d+%c%[%d+[m]?",
        markup.bold(markup.color(bg, fg, os.date("%e")))):gsub("[\n%s]*$", "")

        local widget_focused = true

        if t_out == 0 and mouse.current_widgets then
            widget_focused = false
            for i, widget in ipairs(calendar.attach_to) do
                for _,v in ipairs(mouse.current_widgets) do
                    if widget == v then
                        widget_focused = true
                        break
                    end
                end
            end
        end

        if widget_focused then
            calendar.hide()
            calendar.notification = naughty.notify({
                preset  = calendar.notification_preset,
                icon    = calendar.icon,
                timeout = t_out or calendar.notification_preset.timeout or 5
            })
        end
    end)
end

function calendar.hover_on() calendar.show(0) end
function calendar.hover_off() calendar.hide() end
function calendar.prev() calendar.show(0, -1) end
function calendar.next() calendar.show(0, 1) end

function calendar.attach(widget)
    widget:connect_signal("mouse::enter", calendar.hover_on)
    widget:connect_signal("mouse::leave", calendar.hover_off)
    widget:buttons(awful.util.table.join(
                awful.button({}, 1, calendar.prev),
                awful.button({}, 3, calendar.next),
                awful.button({}, 2, calendar.hover_on),
                awful.button({}, 4, calendar.prev),
                awful.button({}, 5, calendar.next)))
end

local function factory(args)
    local args                   = args or {}
    calendar.cal                 = args.cal or "/usr/bin/cal"
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

return setmetatable(calendar, { __call = function(_, ...) return factory(...) end })
