
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local helpers      = require("lain.helpers")

local notify_fg    = require("beautiful").fg_focus
local naughty      = require("naughty")
local wibox        = require("wibox")

local string       = { format = string.format,
                       gsub   = string.gsub,
                       match  = string.match }

local setmetatable = setmetatable

-- Network infos
-- lain.widgets.net
local net = {}

function net.get_device()
    local ws = helpers.read_pipe("ip link show | cut -d' ' -f2,9")
    ws = ws:match("%w+: UP") or ws:match("ppp%w+: UNKNOWN")
    if ws ~= nil then
        return ws:match("(%w+):")
    else
        return "network off"
    end
end

local function worker(args)
    local args = args or {}
    local timeout = args.timeout or 1
    local units = args.units or 1024 --kb
    local notify = args.notify or "on"
    local screen = args.screen or 1
    local settings = args.settings or function() end

    iface = args.iface or net.get_device()

    net.widget = wibox.widget.textbox('')

    helpers.set_map(iface, true)
    helpers.set_map("net_t", 0)
    helpers.set_map("net_r", 0)

    function update()
        net_now = {
            sent     = "0.0",
            received = "0.0"
        }

        if iface == "" or string.match(iface, "network off")
        then
            iface = net.get_device()
        end

        local now_t = helpers.first_line('/sys/class/net/' .. iface ..
                                           '/statistics/tx_bytes') or 0
        local now_r = helpers.first_line('/sys/class/net/' .. iface ..
                                           '/statistics/rx_bytes') or 0

        if now_t ~= helpers.get_map("net_t")
           or now_r ~= helpers.get_map("net_r") then
            net_now.carrier = helpers.first_line('/sys/class/net/' .. iface ..
                                           '/carrier') or "0"
            net_now.state = helpers.first_line('/sys/class/net/' .. iface ..
                                           '/operstate') or "down"

            net_now.sent = (now_t - net.last_t) / timeout / units
            net_now.sent = string.gsub(string.format('%.1f', net_now.sent), ",", ".")

            net_now.received = (now_r - net.last_r) / timeout / units
            net_now.received = string.gsub(string.format('%.1f', net_now.received), ",", ".")

            widget = net.widget
            settings()

            helpers.set_map("net_t", now_t)
            helpers.set_map("net_r", now_r)
        end

        if net_now.carrier ~= "1" and notify == "on"
        then
            if helpers.get_map(iface)
            then
                naughty.notify({
                    title    = iface,
                    text     = "no carrier",
                    timeout  = 7,
                    position = "top_left",
                    icon     = helpers.icons_dir .. "no_net.png",
                    fg       = notify_fg or "#FFFFFF",
                    screen   = screen
                })
                helpers.set_map(iface, false)
            end
        else
            helpers.set_map(iface, true)
        end
    end

    helpers.newtimer(iface, timeout, update, false)

    return net.widget
end

return setmetatable(net, { __call = function(_, ...) return worker(...) end })
