
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local helpers = require("lain.helpers")
local naughty = require("naughty")
local wibox   = require("wibox")
local string  = { format = string.format, match = string.match }

-- Network infos
-- lain.widget.net

local function factory(args)
    local net      = { widget = wibox.widget.textbox(), devices = {} }
    local args     = args or {}
    local timeout  = args.timeout or 2
    local units    = args.units or 1024 -- KB
    local notify   = args.notify or "on"
    local screen   = args.screen or 1
    local settings = args.settings or function() end

    -- Compatibility with old API where iface was a string corresponding to 1 interface
    net.iface = (args.iface and (type(args.iface) == "string" and {args.iface}) or
                (type(args.iface) == "table" and args.iface)) or {}

    function net.get_device()
        helpers.async(string.format("ip link show", device_cmd), function(ws)
            ws = ws:match("(%w+): <BROADCAST,MULTICAST,.-UP,LOWER_UP>")
            net.iface = ws and { ws } or {}
        end)
    end

    if #net.iface == 0 then net.get_device() end

    function net.update()
        -- These are the totals over all specified interfaces
        net_now = {
            devices  = {},
            -- Bytes since last iteration
            sent     = 0,
            received = 0
        }

        for i, dev in ipairs(net.iface) do
            local dev_now    = {}
            local dev_before = net.devices[dev] or { last_t = 0, last_r = 0 }
            local now_t      = tonumber(helpers.first_line(string.format("/sys/class/net/%s/statistics/tx_bytes", dev)) or 0)
            local now_r      = tonumber(helpers.first_line(string.format("/sys/class/net/%s/statistics/rx_bytes", dev)) or 0)

            dev_now.carrier  = helpers.first_line(string.format("/sys/class/net/%s/carrier", dev)) or "0"
            dev_now.state    = helpers.first_line(string.format("/sys/class/net/%s/operstate", dev)) or "down"

            dev_now.sent     = (now_t - dev_before.last_t) / timeout / units
            dev_now.received = (now_r - dev_before.last_r) / timeout / units

            net_now.sent     = net_now.sent + dev_now.sent
            net_now.received = net_now.received + dev_now.received

            dev_now.sent     = string.format("%.1f", dev_now.sent)
            dev_now.received = string.format("%.1f", dev_now.received)

            dev_now.last_t   = now_t
            dev_now.last_r   = now_r

            net.devices[dev] = dev_now

            -- Notify only once when connection is loss
            if string.match(dev_now.carrier, "0") and notify == "on" and helpers.get_map(dev) then
                naughty.notify {
                    title    = dev,
                    text     = "No carrier",
                    icon     = helpers.icons_dir .. "no_net.png",
                    screen   = screen
                }
                helpers.set_map(dev, false)
            elseif string.match(dev_now.carrier, "1") then
                helpers.set_map(dev, true)
            end

            net_now.carrier = dev_now.carrier
            net_now.state = dev_now.state
            net_now.devices[dev] = dev_now
            -- new_now.sent and net_now.received will be
            -- the totals across all specified devices
        end

        net_now.sent = string.format("%.1f", net_now.sent)
        net_now.received = string.format("%.1f", net_now.received)

        widget = net.widget
        settings()
    end

    helpers.newtimer("network", timeout, net.update)

    return net
end

return factory
