
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
                                                  
--]]

local icons_dir    = require("lain.helpers").icons_dir

local awful        = require("awful")
local beautiful    = require("beautiful")
local naughty      = require("naughty")

local io           = { popen = io.popen }
local os           = { date = os.date }
local mouse        = mouse
local string       = { format = string.format,
                       sub    = string.sub,
                       gsub   = string.gsub }
local tonumber     = tonumber

local setmetatable = setmetatable

-- Calendar notification
-- lain.widgets.calendar
local calendar = {}
local cal_notification = nil

function calendar:hide()
    if cal_notification ~= nil then
        naughty.destroy(cal_notification)
        cal_notification = nil
    end
end

function calendar:show(t_out, inc_offset, scr)
    calendar:hide()

    local f, c_text
    local offs  = inc_offset or 0
    local tims  = t_out or 0
    local today = tonumber(os.date('%d'))

    calendar.offset = calendar.offset + offs

    if offs == 0 or calendar.offset == 0
    then -- current month showing, today highlighted
        calendar.offset = 0
        calendar.notify_icon = calendar.icons .. today .. ".png"

        -- bg and fg inverted to highlight today
		 	  f = io.popen(calendar.cal_format(today))
    else -- no current month showing, no day to highlight
       local month = tonumber(os.date('%m'))
       local year = tonumber(os.date('%Y'))

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
       f = io.popen(string.format('%s %s %s', calendar.cal, month, year))
    end

    c_text = "<tt><span font='" .. calendar.font .. " "
             .. calendar.font_size .. "'><b>"
             .. f:read() .. "</b>\n\n"
             .. f:read() .. "\n"
             .. f:read("*all"):gsub("\n*$", "")
             .. "</span></tt>"
    f:close()

    if calendar.followmouse then
        scrp = mouse.screen
    else
        scrp = scr or calendar.scr_pos
    end

    cal_notification = naughty.notify({
        text = c_text,
        icon = calendar.notify_icon,
        position = calendar.position,
        fg = calendar.fg,
        bg = calendar.bg,
        timeout = tims,
        screen = scrp
    })
end

function calendar:attach(widget, args)
    local args = args or {}

    calendar.cal         = args.cal or "/usr/bin/cal"
    calendar.cal_format  = args.ca_format or function(today)
        return string.format("%s | sed -r -e 's/_\\x08//g' -e '0,/(^| )%d($| )/ s/(^| )%d($| )/\\1<b><span foreground=\"%s\" background=\"%s\">%d<\\/span><\\/b>\\2/'",
                             calendar.cal, today, today, calendar.bg, calendar.fg, today)
    end
    calendar.icons       = args.icons or icons_dir .. "cal/white/"
    calendar.font        = args.font or beautiful.font:gsub(" %d.*", "")
    calendar.font_size   = tonumber(args.font_size) or 11
    calendar.fg          = args.fg or beautiful.fg_normal or "#FFFFFF"
    calendar.bg          = args.bg or beautiful.bg_normal or "#000000"
    calendar.position    = args.position or "top_right"
    calendar.scr_pos     = args.scr_pos or 1
    calendar.followmouse = args.followmouse or false

    calendar.offset      = 0
    calendar.notify_icon = nil

    widget:connect_signal("mouse::enter", function () calendar:show(0, 0, calendar.scr_pos) end)
    widget:connect_signal("mouse::leave", function () calendar:hide() end)
    widget:buttons(awful.util.table.join(awful.button({ }, 1, function ()
                                             calendar:show(0, -1, calendar.scr_pos) end),
                                         awful.button({ }, 3, function ()
                                             calendar:show(0, 1, calendar.scr_pos) end),
                                         awful.button({ }, 4, function ()
                                             calendar:show(0, -1, calendar.scr_pos) end),
                                         awful.button({ }, 5, function ()
                                             calendar:show(0, 1, calendar.scr_pos) end)))
end

return setmetatable(calendar, { __call = function(_, ...) return create(...) end })
