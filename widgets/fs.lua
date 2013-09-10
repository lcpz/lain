
--[[
                                                      
     Licensed under GNU General Public License v2     
      * (c) 2013, Luke Bonham                         
      * (c) 2010, Adrian C.      <anrxc@sysphere.org> 
      * (c) 2009, Lucas de Vries <lucas@glacicle.com> 
                                                      
--]]

local helpers      = require("lain.helpers")

local beautiful    = require("beautiful")
local wibox        = require("wibox")
local naughty      = require("naughty")

local io           = io
local pairs        = pairs
local string       = { match  = string.match,
                       format = string.format }
local tonumber     = tonumber

local setmetatable = setmetatable

-- File system disk space usage
-- lain.widgets.fs
local fs = { notification_preset = {} }
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
        preset = fs.notification_preset,
        text = ws,
      	timeout = t_out
    })
end

-- Units definitions
local unit = { ["mb"] = 1024, ["gb"] = 1024^2 }

local function worker(args)
    local args      = args or {}
    local partition = args.partition or "/"
    local timeout   = args.timeout or 600
    local settings  = args.settings or function() end

    widget = wibox.widget.textbox('')

    helpers.set_map("fs", false)

    function update()
        fs_info = {} 

        local f = io.popen("LC_ALL=C df -kP")

        for line in f:lines() do -- Match: (size) (used)(avail)(use%) (mount)
            local s     = string.match(line, "^.-[%s]([%d]+)")
            local u,a,p = string.match(line, "([%d]+)[%D]+([%d]+)[%D]+([%d]+)%%")
            local m     = string.match(line, "%%[%s]([%p%w]+)")

            if u and m then -- Handle 1st line and broken regexp
                fs_info[m .. " size_mb"]  = string.format("%.1f", tonumber(s) / unit["mb"])
                fs_info[m .. " size_gb"]  = string.format("%.1f", tonumber(s) / unit["gb"])
                fs_info[m .. " used_p"]   = tonumber(p)
                fs_info[m .. " avail_p"]  = 100 - tonumber(p)
            end
        end

        f:close()

        -- chosen partition easy stuff
        -- you can however check whatever partition else
        used = fs_info[partition .. " used_p"]
        available = fs_info[partition .. " avail_p"]
        size_mb = fs_info[partition .. " size_mb"]
        size_gb = fs_info[partition .. " size_gb"]

        notification_preset = { fg = beautiful.fg_normal }

        settings()

        fs.notification_preset = notification_preset

        if used >= 99 and not helpers.get_map("fs")
        then
            naughty.notify({ 
                title = "warning",
                text = partition .. " ran out!\nmake some room",
                timeout = 8,
                fg = "#000000",
                bg = "#FFFFFF"
            })
            helpers.set_map("fs", true)
        else
            helpers.set_map("fs", false)
        end
    end

    helpers.newtimer("fs " .. partition, timeout, update)

    widget:connect_signal('mouse::enter', function () fs:show(0) end)
    widget:connect_signal('mouse::leave', function () fs:hide() end)

    output = {
        widget = widget,
        show = function(t_out)
                   update()
                   fs:show(t_out)
               end
    }

    return setmetatable(output, { __index = output.widget })
end

return setmetatable(fs, { __call = function(_, ...) return worker(...) end })
