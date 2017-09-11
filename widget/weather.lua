--[[

     Licensed under GNU General Public License v2
      * (c) 2015, Luca CPZ

--]]

local helpers  = require("lain.helpers")
local json     = require("lain.util").dkjson
local focused  = require("awful.screen").focused
local naughty  = require("naughty")
local wibox    = require("wibox")

local math, os, string, tonumber = math, os, string, tonumber

-- OpenWeatherMap
-- current weather and X-days forecast
-- lain.widget.weather

local function factory(args)
    local weather               = { widget = wibox.widget.textbox() }
    local args                  = args or {}
    local APPID                 = args.APPID or "3e321f9414eaedbfab34983bda77a66e" -- lain's default
    local timeout               = args.timeout or 60 * 15 -- 15 min
    local timeout_forecast      = args.timeout or 60 * 60 * 24 -- 24 hrs
    local current_call          = args.current_call  or "curl -s 'http://api.openweathermap.org/data/2.5/weather?id=%s&units=%s&lang=%s&APPID=%s'"
    local forecast_call         = args.forecast_call or "curl -s 'http://api.openweathermap.org/data/2.5/forecast/daily?id=%s&units=%s&lang=%s&cnt=%s&APPID=%s'"
    local city_id               = args.city_id or 0 -- placeholder
    local units                 = args.units or "metric"
    local lang                  = args.lang or "en"
    local cnt                   = args.cnt or 5
    local date_cmd              = args.date_cmd or "date -u -d @%d +'%%a %%d'"
    local icons_path            = args.icons_path or helpers.icons_dir .. "openweathermap/"
    local notification_preset   = args.notification_preset or {}
    local notification_text_fun = args.notification_text_fun or
                                  function (wn)
                                      local day = os.date("%a %d", wn["dt"])
                                      local tmin = math.floor(wn["temp"]["min"])
                                      local tmax = math.floor(wn["temp"]["max"])
                                      local desc = wn["weather"][1]["description"]
                                      return string.format("<b>%s</b>: %s, %d - %d ", day, desc, tmin, tmax)
                                  end
    local weather_na_markup     = args.weather_na_markup or " N/A "
    local followtag             = args.followtag or false
    local showpopup             = args.showpopup or "on"
    local settings              = args.settings or function() end

    weather.widget:set_markup(weather_na_markup)
    weather.icon_path = icons_path .. "na.png"
    weather.icon = wibox.widget.imagebox(weather.icon_path)

    function weather.show(t_out)
        weather.hide()

        if followtag then
            notification_preset.screen = focused()
        end

        if not weather.notification_text then
            weather.update()
            weather.forecast_update()
        end

        weather.notification = naughty.notify({
            text    = weather.notification_text,
            icon    = weather.icon_path,
            timeout = t_out,
            preset  = notification_preset
        })
    end

    function weather.hide()
        if weather.notification then
            naughty.destroy(weather.notification)
            weather.notification = nil
        end
    end

    function weather.attach(obj)
        obj:connect_signal("mouse::enter", function()
            weather.show(0)
        end)
        obj:connect_signal("mouse::leave", function()
            weather.hide()
        end)
    end

    function weather.forecast_update()
        local cmd = string.format(forecast_call, city_id, units, lang, cnt, APPID)
        helpers.async(cmd, function(f)
            local pos, err
            weather_now, pos, err = json.decode(f, 1, nil)

            if not err and type(weather_now) == "table" and tonumber(weather_now["cod"]) == 200 then
                weather.notification_text = ""
                for i = 1, weather_now["cnt"] do
                    weather.notification_text = weather.notification_text ..
                                                notification_text_fun(weather_now["list"][i])
                    if i < weather_now["cnt"] then
                        weather.notification_text = weather.notification_text .. "\n"
                    end
                end
            end
        end)
    end

    function weather.update()
        local cmd = string.format(current_call, city_id, units, lang, APPID)
        helpers.async(cmd, function(f)
            local pos, err, icon
            weather_now, pos, err = json.decode(f, 1, nil)

            if not err and type(weather_now) == "table" and tonumber(weather_now["cod"]) == 200 then
                local sunrise = tonumber(weather_now["sys"]["sunrise"])
                local sunset  = tonumber(weather_now["sys"]["sunset"])
                local icon    = weather_now["weather"][1]["icon"]
                local loc_now = os.time() -- local time
                local loc_m   = os.time { year = os.date("%Y"), month = os.date("%m"), day = os.date("%d"), hour = 0 } -- local time from midnight
                local loc_d   = os.date("*t",  loc_now) -- table YMDHMS for current local time (for TZ calculation)
                local utc_d   = os.date("!*t", loc_now) -- table YMDHMS for current UTC time
                local utc_now = os.time(utc_d) -- UTC time now
                local offdt   = (loc_d.isdst and 1 or 0) * 3600 + 100 * (loc_d.min  - utc_d.min) / 60 -- DST offset
                local offset  = os.difftime(loc_now, utc_now) + (loc_d.isdst and 1 or 0) * 3600 + 100 * (loc_d.min  - utc_d.min) / 60 -- TZ offset (including DST)
                local offday  = (offset < 0 and -86400) or 86400 -- 24 hour correction value (+86400 or -86400)

                -- if current UTC time is earlier then local midnight -> positive offset (negative otherwise)
                if offset * (loc_m - utc_now + offdt) > 0 then
                    sunrise = sunrise + offday -- Shift sunset and sunrise times by 24 hours
                    sunset  = sunset  + offday
                end

                if sunrise <= loc_now and loc_now <= sunset then
                    icon = string.gsub(icon, "n", "d")
                else
                    icon = string.gsub(icon, "d", "n")
                end

                weather.icon_path = icons_path .. icon .. ".png"
                widget = weather.widget
                settings()
            else
                weather.icon_path = icons_path .. "na.png"
                weather.widget:set_markup(weather_na_markup)
            end

            weather.icon:set_image(weather.icon_path)
        end)
    end

    if showpopup == "on" then weather.attach(weather.widget) end

    weather.timer = helpers.newtimer("weather-" .. city_id, timeout, weather.update, false, true)
    weather.timer_forecast = helpers.newtimer("weather_forecast-" .. city_id, timeout, weather.forecast_update, false, true)

    return weather
end

return factory
