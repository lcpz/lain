local wibox     = require("wibox")
local helpers   = require("lain.helpers")

function factory(args)
    local wifi      =  { widget = wibox.widget.textbox() }
    local args      = args or {}
    local timeout   = args.timeout or 2
    local settings  = args.settings or function() end
         
    function wifi.is_connected()
        conn_flag = io.popen("[[ ! -z `ping -c 1 -w 3 46.51.218.82` ]] && echo 1"):read()
        if conn_flag == "1" then
            return true
        end
        return false
    end

    function wifi.get_device()
        return io.popen("nmcli -t -f DEVICE dev"):read()
    end

    function wifi.update()
        wifi_now = {
            device = args.device or wifi.get_device(),
            ssid = args.ssid_placeholder or "N/A",
            signal = args.signal_placeholder or "N/A",
            connected = false
        }

        if wifi.is_connected() then
            cmd_ssid = "nmcli -t -f SSID dev wifi list ifname " .. wifi_now.device
            cmd_sigl = "nmcli -t -f SIGNAL dev wifi list ifname " .. wifi_now.device
            ssid_out = io.popen(cmd_ssid):read()
            signal_out = io.popen(cmd_sigl):read()
            if not (ssid_out == nil or signal_out == nil) then
                wifi_now.ssid = ssid_out
                wifi_now.signal = signal_out
            end
            wifi_now.connected = true
        end

        widget = wifi.widget
        settings()
    end

    helpers.newtimer("wifi", timeout, wifi.update)

    return wifi
end

return factory
