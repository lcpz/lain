
--[[
                                                      
     Licensed under GNU General Public License v2     
      * (c) 2013, Luke Bonham                         
      * (c) 2010, Adrian C.      <anrxc@sysphere.org> 
      * (c) 2009, Lucas de Vries <lucas@glacicle.com> 
                                                      
--]]

local helpers      = require("lain.helpers")

local beautiful    = require("beautiful")
local focused      = require("awful.screen").focused
local wibox        = require("wibox")
local naughty      = require("naughty")

local io           = { popen  = io.popen }
local pairs        = pairs
local string       = { match  = string.match,
                       format = string.format }
local tonumber     = tonumber

local setmetatable = setmetatable

-- File system disk space usage
-- lain.widgets.fs
local fs = {}
local fs_notification  = nil

function fs.hide()
    if fs_notification ~= nil then
        naughty.destroy(fs_notification)
        fs_notification = nil
    end
end

function fs.show(seconds, options, scr)
    fs.hide()

    local cmd = (options and string.format("dfs %s", options)) or "dfs"
    local ws = helpers.read_pipe(helpers.scripts_dir .. cmd):gsub("\n*$", "")

    if fs.followtag then
        fs.notification_preset.screen = focused()
    elseif scr then
        fs.notification_preset.screen = scr
    end

    fs_notification = naughty.notify({
        preset  = fs.notification_preset,
        text    = ws,
        timeout = seconds or 5
    })
end

-- Unit definitions
local unit = { ["mb"] = 1024, ["gb"] = 1024^2 }

local function worker(args)
    local args             = args or {}
    local timeout          = args.timeout or 600
    local partition        = args.partition or "/"
    local showpopup        = args.showpopup or "on"
    local notify           = args.notify or "on"
    local settings         = args.settings or function() end

    fs.followtag           = args.followtag or false
    fs.notification_preset = args.notification_preset or { fg = beautiful.fg_normal }

    fs.widget = wibox.widget.textbox('')

    helpers.set_map(partition, false)

    function update()
        fs_info = {}
        fs_now  = {}
        local f = assert(io.popen("LC_ALL=C df -kP"))

        for line in f:lines() do -- Match: (size) (used)(avail)(use%) (mount)
            local s     = string.match(line, "^.-[%s]([%d]+)")
            local u,a,p = string.match(line, "([%d]+)[%D]+([%d]+)[%D]+([%d]+)%%")
            local m     = string.match(line, "%%[%s]([%p%w]+)")

            if u and m then -- Handle 1st line and broken regexp
                fs_info[m .. " size_mb"]  = string.format("%.1f", tonumber(s) / unit["mb"])
                fs_info[m .. " size_gb"]  = string.format("%.1f", tonumber(s) / unit["gb"])
                fs_info[m .. " used_mb"]  = string.format("%.1f", tonumber(u) / unit["mb"])
                fs_info[m .. " used_gb"]  = string.format("%.1f", tonumber(u) / unit["gb"])
                fs_info[m .. " used_p"]   = tonumber(p)
                fs_info[m .. " avail_p"]  = 100 - tonumber(p)
            end
        end

        f:close()

        fs_now.available = tonumber(fs_info[partition .. " avail_p"]) or 0
        fs_now.size_mb   = tonumber(fs_info[partition .. " size_mb"]) or 0
        fs_now.size_gb   = tonumber(fs_info[partition .. " size_gb"]) or 0
        fs_now.used      = tonumber(fs_info[partition .. " used_p"])  or 0
        fs_now.used_mb   = tonumber(fs_info[partition .. " used_mb"]) or 0
        fs_now.used_gb   = tonumber(fs_info[partition .. " used_gb"]) or 0

        notification_preset = fs.notification_preset
        widget = fs.widget
        settings()

        if notify == "on" and fs_now.used >= 99 and not helpers.get_map(partition)
        then
            naughty.notify({
                title = "warning",
                text = partition .. " ran out!\nmake some room",
                timeout = 8,
                fg = "#000000",
                bg = "#FFFFFF",
            })
            helpers.set_map(partition, true)
        else
            helpers.set_map(partition, false)
        end
    end

    if showpopup == "on" then
       fs.widget:connect_signal('mouse::enter', function () fs.show(0) end)
       fs.widget:connect_signal('mouse::leave', function () fs.hide() end)
    end

    helpers.newtimer(partition, timeout, update)

    return setmetatable(fs, { __index = fs.widget })
end

return setmetatable(fs, { __call = function(_, ...) return worker(...) end })
