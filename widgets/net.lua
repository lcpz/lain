
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local markup       = require("lain.util.markup")
local helpers      = require("lain.helpers")

local awful        = require("awful")
local beautiful    = require("beautiful")
local wibox        = require("wibox")

local io           = io
local tostring     = tostring
local string       = { format = string.format }

local setmetatable = setmetatable

-- Network infos
-- lain.widgets.net
local net = {
    send = "0",
    recv = "0",
    last_t = {},
    last_r = {}
}

net.units = {
    ["b"] = 1,
    ["kb"] = 1024,
    ["mb"] = 1024^2,
    ["gb"] = 1024^3
}

function net.get_device()
    f = io.popen("ip link show | cut -d' ' -f2,9")
    ws = f:read("*all")
    f:close()
    ws = ws:match("%w+: UP")
    if ws ~= nil then
        return ws:gsub(": UP", "")
    else
        return ""
    end
end

function worker(args)
    local args = args or {}
    local iface = args.iface or net.get_device()
    local delta = args.refresh_timeout or 2
    local units = args.units or net.units["kb"]
    local spr = args.spr or " "
    local header = args.header or iface
    local header_color = args.header_color or beautiful.fg_normal or "#FFFFFF"
    local color_up = args.color_up or beautiful.fg_focus or "#FFFFFF"
    local color_down = args.color_down or beautiful.fg_focus or "#FFFFFF"
    local app = args.app or "sudo wifi-menu"

    helpers.set_map(iface, true)
    helpers.set_map("carrier", 0)

    local mynet = wibox.widget.textbox()

    local mynetupdate = function()
        if iface == "" then
            iface = net.get_device()
            header = iface
        end

        local carrier = helpers.first_line('/sys/class/net/' .. iface ..
                                           '/carrier') or ""
        local state = helpers.first_line('/sys/class/net/' .. iface ..
                                           '/operstate')
        local now_t = helpers.first_line('/sys/class/net/' .. iface ..
                                           '/statistics/tx_bytes')
        local now_r = helpers.first_line('/sys/class/net/' .. iface ..
                                           '/statistics/rx_bytes')
        local text = '<span color="' .. header_color .. '">' .. header .. '</span> '

        if carrier ~= "1"
        then
            if helpers.get_map(iface)
            then
                n_title = iface
                if n_title == "" then
                    n_title = "network"
                    header = "Net"
                end
                naughty.notify({ title = n_title, text = "no carrier",
                                 timeout = 7,
                                 position = "top_left",
                                 icon = beautiful.lain_no_net_notify or
                                        helpers.icons_dir .. "no_net.png",
                                 fg = beautiful.fg_focus or "#FFFFFF" })

                mynet:set_markup(markup(header_color, header) .. markup(color_up, " Off"))
                helpers.set_map(iface, false)
            end
            return
        else
            helpers.set_map(iface, true)
        end

        if state == 'down' or not now_t or not now_r
        then
            mynet:set_markup(' ' .. text .. '-' .. ' ')
            return
        end

        if net.last_t[iface] and net.last_t[iface]
        then
            net.send = tostring((now_t - net.last_t[iface]) / delta / units)
            net.recv = tostring((now_r - net.last_r[iface]) / delta / units)

            text = text
                   .. '<span color="' .. color_up .. '">'
                   .. string.format('%.1f', net.send)
                   .. '</span>'
                   ..  spr
                   .. '<span color="' .. color_down .. '">'
                   .. string.format('%.1f', net.recv)
                   .. '</span>'

            mynet:set_markup(' ' .. text .. ' ')
        else
            mynet:set_markup(' ' .. text .. '-' .. ' ')
        end

        net.last_t[iface] = now_t
        net.last_r[iface] = now_r
    end

    local mynettimer = timer({ timeout = delta })
    mynettimer:connect_signal("timeout", mynetupdate)
    mynettimer:start()
    mynettimer:emit_signal("timeout")

    mynet:buttons(awful.util.table.join(
            awful.button({}, 0, function()
                helpers.run_in_terminal(app)
                mynetupdate()
            end)))

    net.widget = mynet

    return setmetatable(net, { __index = net.widget })
end

return setmetatable(net, { __call = function(_, ...) return worker(...) end })
