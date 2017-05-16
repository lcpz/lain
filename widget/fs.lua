
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
                                                  
--]]

local helpers  = require("lain.helpers")
local shell    = require("awful.util").shell
local focused  = require("awful.screen").focused
local wibox    = require("wibox")
local naughty  = require("naughty")
local string   = string
local tonumber = tonumber

-- File system disk space usage
-- lain.widget.fs

local function factory(args)
    local fs = { unit  = { ["mb"] = 1024, ["gb"] = 1024^2 }, widget = wibox.widget.textbox() }

    function fs.hide()
        if not fs.notification then return end
        naughty.destroy(fs.notification)
        fs.notification = nil
    end

    function fs.show(seconds, scr)
        fs.update()
        fs.hide()

        if fs.followtag then
            fs.notification_preset.screen = focused()
        else
            fs.notification_preset.screen = scr or 1
        end

        fs.notification = naughty.notify({
            preset  = fs.notification_preset,
            timeout = seconds or 5
        })
    end

    local args             = args or {}
    local timeout          = args.timeout or 600
    local partition        = args.partition or "/"
    local showpopup        = args.showpopup or "on"
    local notify           = args.notify or "on"
    local settings         = args.settings or function() end

    fs.options             = args.options
    fs.followtag           = args.followtag or false
    fs.notification_preset = args.notification_preset

    if not fs.notification_preset then
        fs.notification_preset = {
            font = "Monospace 10",
            fg   = "#FFFFFF",
            bg   = "#000000"
        }
    end

    helpers.set_map(partition, false)

    function fs.update()
        fs_info, fs_now  = {}, {}
        helpers.async({ shell, "-c", "/usr/bin/env LC_ALL=C df -k --output=target,size,used,avail,pcent" }, function(f)
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

            if notify == "on" and tonumber(fs_now.used) and tonumber(fs_now.used) >= 99 and not helpers.get_map(partition) then
                naughty.notify({
                    preset = naughty.config.presets.critical,
                    title  = "Warning",
                    text   = partition .. " is full",
                })
                helpers.set_map(partition, true)
            else
                helpers.set_map(partition, false)
            end
        end)

        local notifycmd = (fs.options and string.format("dfs %s", fs.options)) or "dfs"
        helpers.async(helpers.scripts_dir .. notifycmd, function(ws)
            fs.notification_preset.text = ws:gsub("\n*$", "")
        end)
    end

    if showpopup == "on" then
       fs.widget:connect_signal('mouse::enter', function () fs.show(0) end)
       fs.widget:connect_signal('mouse::leave', function () fs.hide() end)
    end

    helpers.newtimer(partition, timeout, fs.update)

    return fs
end

return factory
