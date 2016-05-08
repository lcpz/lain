
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local helpers      = require("lain.helpers")
local naughty      = require("naughty")
local wibox        = require("wibox")

local string       = { format = string.format,
                       gsub   = string.gsub,
                       match  = string.match }

local setmetatable = setmetatable

-- Network infos
-- lain.widgets.net

local function worker(args)
    local net = { last_t = 0, last_r = 0 }

    function net.get_first_device()
        local ws = helpers.read_pipe("ip link show | cut -d' ' -f2,9")
        ws = ws:match("%w+: UP") or ws:match("ppp%w+: UNKNOWN")
        if ws then return { ws:match("(%w+):") }
        else return {} end
    end

    local args     = args or {}
    local timeout  = args.timeout or 2
    local units    = args.units or 1024 --kb
    local notify   = args.notify or "on"
    local screen   = args.screen or 1
    local settings = args.settings or function() end
    local iface    = args.iface or net.get_first_device()

    net.widget = wibox.widget.textbox('')

    -- Compatibility with old API where iface was a string corresponding to 1 interface
    if type(iface) == "string" then
        iftable = {iface}
    else
        iftable = iface
    end

    -- Mark all devices as initially online/active
    for i, dev in ipairs(iftable) do
        helpers.set_map(dev, true)
    end

    function update()
        -- These are the totals over all specified interfaces
        net_now = {
            sent     = 0,
            received = 0
        }

        -- Total bytes transfered
        local total_t = 0
        local total_r = 0

        for i, dev in ipairs(iftable) do
            local dev_now = {}
            local dev_before = net_now[dev] or net

            dev_now.carrier  = helpers.first_line(string.format('/sys/class/net/%s/carrier', dev)) or '0'
            dev_now.state    = helpers.first_line(string.format('/sys/class/net/%s/operstate', dev)) or 'down'

            local now_t      = tonumber(helpers.first_line(string.format('/sys/class/net/%s/statistics/tx_bytes', dev)) or 0)
            local now_r      = tonumber(helpers.first_line(string.format('/sys/class/net/%s/statistics/rx_bytes', dev)) or 0)

            if now_t ~= dev_before.last_t or now_r ~= dev_before.last_r then
                dev_now.sent     = (now_t - (dev_before.last_t or 0)) / timeout / units
                net_now.sent     = net_now.sent + dev_now.sent
                dev_now.sent     = string.gsub(string.format('%.1f', dev_now.sent), ',', '.')
                dev_now.received = (now_r - (dev_before.last_r or 0)) / timeout / units
                net_now.received = net_now.received + dev_now.received
                dev_now.received = string.gsub(string.format('%.1f', dev_now.received), ',', '.')
            end

            total_t  = total_t + now_t
            total_r  = total_r + now_r

            net_now[dev] = dev_now

            if string.match(dev_now.carrier, "0") and notify == "on" and helpers.get_map(dev) then
                naughty.notify({
                    title    = dev,
                    text     = "no carrier",
                    icon     = helpers.icons_dir .. "no_net.png",
                    screen   = screen
                })
                helpers.set_map(dev, false)
            else
                helpers.set_map(dev, true)
            end
        end

        if total_t ~= net.last_t or total_r ~= net.last_r then
            net_now.sent     = string.gsub(string.format('%.1f', net_now.sent), ',', '.')
            net_now.received = string.gsub(string.format('%.1f', net_now.received), ',', '.')

            widget = net.widget
            settings()

            net.last_t = total_t
            net.last_r = total_r
        end
    end

    helpers.newtimer(iface, timeout, update)

    return setmetatable(net, { __index = net.widget })
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
