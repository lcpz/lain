
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
    local net = helpers.make_widget_textbox()
    net.last_t = 0
    net.last_r = 0
    net.devices = {}

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
        -- This check is required to ensure we keep looking for one device if
        -- none is found by net.get_first_device() at startup (i.e. iftable = {})
        if next(iftable) == nil then
            iftable = net.get_first_device()
        end

        -- These are the totals over all specified interfaces
        net_now = {
            -- New api - Current state of requested devices
            devices  = {},
            -- Bytes since last iteration
            sent     = 0,
            received = 0
        }

        -- Total bytes transfered
        local total_t = 0
        local total_r = 0

        for i, dev in ipairs(iftable) do
            local dev_now = {}
            local dev_before = net.devices[dev] or { last_t = 0, last_r = 0 }

            dev_now.carrier  = helpers.first_line(string.format('/sys/class/net/%s/carrier', dev)) or '0'
            dev_now.state    = helpers.first_line(string.format('/sys/class/net/%s/operstate', dev)) or 'down'

            local now_t      = tonumber(helpers.first_line(string.format('/sys/class/net/%s/statistics/tx_bytes', dev)) or 0)
            local now_r      = tonumber(helpers.first_line(string.format('/sys/class/net/%s/statistics/rx_bytes', dev)) or 0)

            dev_now.sent     = (now_t - dev_before.last_t) / timeout / units
            dev_now.received = (now_r - dev_before.last_r) / timeout / units

            net_now.sent     = net_now.sent     + dev_now.sent
            net_now.received = net_now.received + dev_now.received

            dev_now.sent     = string.gsub(string.format('%.1f', dev_now.sent), ',', '.')
            dev_now.received = string.gsub(string.format('%.1f', dev_now.received), ',', '.')

            dev_now.last_t   = now_t
            dev_now.last_r   = now_r

            -- This will become dev_before in the next update/iteration
            net.devices[dev] = dev_now

            total_t  = total_t + now_t
            total_r  = total_r + now_r

            -- Notify only once when connection is loss
            if string.match(dev_now.carrier, "0") and notify == "on" and helpers.get_map(dev) then
                naughty.notify({
                    title    = dev,
                    text     = "no carrier",
                    icon     = helpers.icons_dir .. "no_net.png",
                    screen   = screen
                })
                helpers.set_map(dev, false)
            elseif string.match(dev_now.carrier, "1") then
                helpers.set_map(dev, true)
            end

            -- Old api compatibility
            net_now.carrier      = dev_now.carrier
            net_now.state        = dev_now.state
            -- And new api
            net_now.devices[dev] = dev_now
            -- With the new api new_now.sent and net_now.received will be the
            -- totals across all specified devices

        end

        if total_t ~= net.last_t or total_r ~= net.last_r then
            -- Convert to a string to round the digits after the float point
            net_now.sent     = string.gsub(string.format('%.1f', net_now.sent), ',', '.')
            net_now.received = string.gsub(string.format('%.1f', net_now.received), ',', '.')

            net.last_t = total_t
            net.last_r = total_r
        end

        widget = net.widget
        settings()
    end

    helpers.newtimer(iface, timeout, update)

    return net
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
