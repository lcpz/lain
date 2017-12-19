local awful     = require("awful")
local wibox     = require("wibox")
local helpers   = require("lain.helpers")

function factory(args)
    local wifi      =  { widget = wibox.widget.textbox() }
    local args      = args or {}
    local timeout   = args.timeout or 2
    local settings  = args.settings or function() end
         
    local command = {
        check_conn = "[ ! -z \"`ping -c1 -w3 www.duckduckgo.com`\" ] && echo -n 1",
        nmcli_dev = "nmcli -t dev | grep -E ^wl",
        nmcli_wifi = "nmcli -g IN-USE,SSID,SIGNAL dev wifi list | grep -F \"*\"",
    }

    wifi_now = {
        device = args.device or "N/A",
        connected = false,
        ssid = args.ssid_placeholder or "N/A",
        signal = args.signal_placeholder or "N/A",
    }

    function wifi.shell_cmd(cmd)
        return awful.util.shell .. " -c '" .. cmd .. "'"
    end

    function wifi.update()

        awful.spawn.easy_async(wifi.shell_cmd(command.check_conn),
            function(stdout, stderr, reason, exit_code)
                -- sub(1,1) because of trailing new line in stdout.
                if stdout:sub(1, 1) == "1" then
                    wifi_now.connected = true
                end
            end
        )

        -- Only update wifi information if connected to internet.
        if wifi_now.connected then
            if not args.device then
                awful.spawn.easy_async(wifi.shell_cmd(command.nmcli_dev),
                    function(stdout, stderr, reason, exit_code)
                        local dev = string.match(stdout, "^(wl.-):")
                        wifi_now.device = dev
                    end
                )
            else
                wifi_now.device = args.device
            end

            awful.spawn.easy_async(wifi.shell_cmd(command.nmcli_wifi),
                function(stdout, stderr, reason, exit_code)
                    local ssid, signal = string.match(stdout, ":(.-):(%d+)")
                    wifi_now.ssid = ssid
                    wifi_now.signal = signal
                end
            )
        end

        widget = wifi.widget
        settings()
    end

    helpers.newtimer("wifi", timeout, wifi.update)

    return wifi
end

return factory
