
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
                                                  
--]]

local helpers      = require("lain.helpers")

local shell        = require("awful.util").shell
local beautiful    = require("beautiful")
local focused      = require("awful.screen").focused
local wibox        = require("wibox")
local naughty      = require("naughty")

local string       = string
local tonumber     = tonumber

local setmetatable = setmetatable

-- File system disk space usage
-- lain.widgets.fs
local fs = {}

-- Unit definitions
fs.unit = { ["mb"] = 1024, ["gb"] = 1024^2 }

function fs.hide()
    if not fs.notification then return end
    naughty.destroy(fs.notification)
    fs.notification = nil
end

function fs.show(seconds, scr)
    fs.hide()

    if fs.followtag then
        fs.notification_preset.screen = focused()
    elseif scr then
        fs.notification_preset.screen = scr
    end

    local cmd = (fs.options and string.format("dfs %s", fs.options)) or "dfs"

    helpers.async(helpers.scripts_dir .. cmd, function(ws)
        fs.notification = naughty.notify({
            preset      = fs.notification_preset,
            text        = ws:gsub("\n*$", ""),
            timeout     = seconds or 5,
        })
    end)
end

local function worker(args)
    local args             = args or {}
    local timeout          = args.timeout or 600
    local partition        = args.partition or "/"
    local showpopup        = args.showpopup or "on"
    local notify           = args.notify or "on"
    local settings         = args.settings or function() end

    fs.options             = args.options
    fs.followtag           = args.followtag or false
    fs.notification_preset = args.notification_preset or { fg = beautiful.fg_normal }

    fs.widget = wibox.widget.textbox()

    helpers.set_map(partition, false)


    function update()
        fs_info, fs_now  = {}, {}
        helpers.async(string.format("%s -c 'LC_ALL=C df -k --output=target,size,used,avail,pcent'", shell), function(f)
            for line in string.gmatch(f, "\n[^\n]+") do
                local m,s,u,a,p = string.match(line, "(/.-%s).-(%d+).-(%d+).-(%d+).-([%d]+)%%")
                m = m:gsub(" ", "") -- clean target from any whitespace

                fs_info[m .. " size_mb"]  = string.format("%.1f", tonumber(s) / fs.unit["mb"])
                fs_info[m .. " size_gb"]  = string.format("%.1f", tonumber(s) / fs.unit["gb"])
                fs_info[m .. " used_mb"]  = string.format("%.1f", tonumber(u) / fs.unit["mb"])
                fs_info[m .. " used_gb"]  = string.format("%.1f", tonumber(u) / fs.unit["gb"])
                fs_info[m .. " used_p"]   = p
                fs_info[m .. " avail_mb"] = string.format("%.1f", tonumber(a) / fs.unit["mb"])
                fs_info[m .. " avail_gb"] = string.format("%.1f", tonumber(a) / fs.unit["gb"])
                fs_info[m .. " avail_p"]  = string.format("%d", 100 - tonumber(p))
            end

            fs_now.size_mb      = fs_info[partition .. " size_mb"]  or "N/A"
            fs_now.size_gb      = fs_info[partition .. " size_gb"]  or "N/A"
            fs_now.used         = fs_info[partition .. " used_p"]   or "N/A"
            fs_now.used_mb      = fs_info[partition .. " used_mb"]  or "N/A"
            fs_now.used_gb      = fs_info[partition .. " used_gb"]  or "N/A"
            fs_now.available    = fs_info[partition .. " avail_p"]  or "N/A"
            fs_now.available_mb = fs_info[partition .. " avail_mb"] or "N/A"
            fs_now.available_gb = fs_info[partition .. " avail_gb"] or "N/A"

            notification_preset = fs.notification_preset
            widget = fs.widget
            settings()

            if notify == "on" and tonumber(fs_now.used) >= 99 and not helpers.get_map(partition) then
                naughty.notify({
                    title   = "warning",
                    text    = partition .. " is empty!",
                    timeout = 8,
                    fg      = "#000000",
                    bg      = "#FFFFFF"
                })
                helpers.set_map(partition, true)
            else
                helpers.set_map(partition, false)
            end
        end)
    end

    if showpopup == "on" then
       fs.widget:connect_signal('mouse::enter', function () fs.show(0) end)
       fs.widget:connect_signal('mouse::leave', function () fs.hide() end)
    end

    helpers.newtimer(partition, timeout, update)

    return setmetatable(fs, { __index = fs.widget })
end

return setmetatable(fs, { __call = function(_, ...) return worker(...) end })
