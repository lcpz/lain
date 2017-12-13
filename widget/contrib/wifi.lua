local wibox     = require("wibox")
local helpers   = require("lain.helpers")

function factory(args)
    local wifi      =  { widget = wibox.widget.textbox() }
    local args      = args or {}
    local timeout   = args.timeout or 2
    local settings  = args.settings or function() end
         
    function wifi.is_connected()
        conn_flag = io.popen("[[ ! -z `ping -c 1 -w 3 www.duckduckgo.com` ]] && echo true"):read()
        if conn_flag == "true" then
            return true
        end
        return false
    end

    function wifi.update()
        wifi_now = {
            ssid = "N/A",
            signal = "/NA",
            enable_signal = true,
            connected = false
        }

        if wifi.is_connected() then
            wifi_now.ssid = io.popen("nmcli -t -f SSID dev wifi list"):read()

            if wifi_now.enable_signal then
                wifi_now.signal = io.popen("nmcli -t -f SIGNAL dev wifi list"):read()
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
