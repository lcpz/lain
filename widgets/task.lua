
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Jan Xie
                                                  
--]]

local icons_dir    = require("lain.helpers").icons_dir

local awful        = require("awful")
local beautiful    = require("beautiful")
local naughty      = require("naughty")

local io           = io
local tonumber     = tonumber

local setmetatable = setmetatable

-- task notification
-- lain.widgets.task
local task = {}
local task_notification = nil

function task:hide()
    if task_notification ~= nil then
        naughty.destroy(task_notification)
        task_notification = nil
    end
end

function task:show(t_out)
    task:hide()

    local tims = t_out or 0
    local f, c_text
    -- let's take font only, font size is set in task table
    local font = beautiful.font:sub(beautiful.font:find(""),
                 beautiful.font:find(" "))


    f = io.popen('task')
    c_text = "<tt><span font='" .. font .. " "
             .. task.font_size+2 .. "'><b>Tasks next</b></span>\n"
             .. "<span font='" .. font .. " "
             .. task.font_size .. "'>"
             .. f:read("*all") .. "\n"
             .. "</span></tt>"
    f:close()

    task_notification = naughty.notify({ text = c_text,
                                        icon = task.notify_icon,
                                        position = task.position,
                                        fg = task.fg,
                                        bg = task.bg,
                                        timeout = tims })
end

function task:attach(widget, args)
    local args = args or {}
    task.font_size = tonumber(args.font_size) or 12
    task.fg = args.fg or beautiful.fg_normal or "#FFFFFF"
    task.bg = args.bg or beautiful.bg_normal or "#FFFFFF"
    task.position = args.position or "top_right"

    task.notify_icon = icons_dir .. "taskwarrior.png"

    widget:connect_signal("mouse::enter", function () task:show() end)
    widget:connect_signal("mouse::leave", function () task:hide() end)
    widget:buttons(awful.util.table.join( awful.button({ }, 1, function ()
                                              task:show(0, -1) end),
                                          awful.button({ }, 3, function ()
                                              task:show(0, 1) end) ))
end

return setmetatable(task, { __call = function(_, ...) return create(...) end })
