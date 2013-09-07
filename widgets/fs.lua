
--[[
                                                      
     Licensed under GNU General Public License v2     
      * (c) 2013, Luke Bonham                         
      * (c) 2010, Adrian C.      <anrxc@sysphere.org> 
      * (c) 2009, Lucas de Vries <lucas@glacicle.com> 
                                                      
--]]

local markup       = require("lain.util.markup")
local helpers      = require("lain.helpers")

local beautiful    = require("beautiful")
local wibox        = require("wibox")
local naughty      = require("naughty")

local io           = io
local string       = { match = string.match }
local tonumber     = tonumber

local setmetatable = setmetatable

-- File system disk space usage
-- lain.widgets.fs
local fs = {}
local notification = nil

function fs:hide()
    if notification ~= nil then
        naughty.destroy(notification)
        notification = nil
    end
end

function fs:show(t_out)
    fs:hide()

    local f = io.popen(helpers.scripts_dir .. "dfs")
    ws = f:read("*all"):gsub("\n*$", "")
    f:close()

    notification = naughty.notify({
        text = ws,
      	timeout = t_out,
        fg = beautiful.fg_focus,
    })
end

-- Variable definitions
local unit = { ["mb"] = 1024, ["gb"] = 1024^2 }

local function worker(args)
    local args = args or {}
    local partition = args.partition or "/"
    local refresh_timeout = args.refresh_timeout or 600
    local header = args.header or " Hdd "
    local header_color = args.header_color or beautiful.fg_normal or "#FFFFFF"
    local color = args.color or beautiful.fg_focus or "#FFFFFF"
    local footer = args.header or ""
    local shadow = args.shadow or false

    local myfs = wibox.widget.textbox()

    helpers.set_map("fs", false)

    local fsupdate = function()
        local fs_info = {} -- Get data from df
        local f = io.popen("LC_ALL=C df -kP")

        local function set_text()
            local info = fs_info['{' .. partition .. ' used_p}']
            myfs:set_markup(markup(header_color, header)
                            .. markup(color, info .. footer) .. " ")
        end

        for line in f:lines() do -- Match: (size) (used)(avail)(use%) (mount)
            local s     = string.match(line, "^.-[%s]([%d]+)")
            local u,a,p = string.match(line, "([%d]+)[%D]+([%d]+)[%D]+([%d]+)%%")
            local m     = string.match(line, "%%[%s]([%p%w]+)")

            if u and m then -- Handle 1st line and broken regexp
                helpers.uformat(fs_info, m .. " used",  u, unit)
                fs_info["{" .. m .. " used_p}"]  = tonumber(p)
            end
        end

        f:close()

        if shadow
        then
            myfs:set_text('')
        else
            set_text()
        end

        local part = fs_info['{' .. partition .. ' used_p}']

        if part >= 90  then
            if part >= 99 and not helpers.get_map("fs") then
                naughty.notify({ title = "warning",
                                 text = partition .. " ran out!\n"
                                        .. "make some room",
                                 timeout = 8,
                                 position = "top_right",
                                 fg = beautiful.fg_urgent,
                                 bg = beautiful.bg_urgent })
                helpers.set_map("fs", true)
            end
            if shadow then set_text() end
        end
    end

    local fstimer = timer({ timeout = refresh_timeout })
    fstimer:connect_signal("timeout", fsupdate)
    fstimer:start()
    fstimer:emit_signal("timeout")

    myfs:connect_signal('mouse::enter', function () fs:show(0) end)
    myfs:connect_signal('mouse::leave', function () fs:hide() end)

    local fs_out =
    {
        widget = myfs,
        show = function(t_out)
                   fsupdate()
                   fs:show(t_out)
               end
    }

    return setmetatable(fs_out, { __index = fs_out.widget })
end

return setmetatable(fs, { __call = function(_, ...) return worker(...) end })
