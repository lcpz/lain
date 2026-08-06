--[[

     Licensed under GNU General Public License v2
      * (c) 2015, Luca CPZ

--]]

local helpers  = require("lain.helpers")
local json     = require("lain.util").dkjson
local focused  = require("awful.screen").focused
local naughty  = require("naughty")
local wibox    = require("wibox")
local math     = math
local os       = os
local string   = string
local type     = type
local tonumber = tonumber

-- OpenWeatherMap
-- current weather and 5d/3h forecast
-- lain.widget.weather

local function factory(args)
    args                        = args or {}

    -- weather.now will hold the 'current' and 'forecast' state
    local weather               = { widget = args.widget or wibox.widget.textbox(), now = {} }
    local APPID                 = args.APPID -- mandatory api key
    local timeout               = args.timeout or 900 -- 15 min
    local current_uri           = args.current_uri or "https://api.openweathermap.org/data/2.5/weather?lat=%s&lon=%s&APPID=%s&units=%s&lang=%s"
    local forecast_uri          = args.forecast_uri or "https://api.openweathermap.org/data/2.5/forecast?lat=%s&lon=%s&APPID=%s&cnt=%s&units=%s&lang=%s"
    local lat                   = args.lat or 0 -- placeholder
    local lon                   = args.lon or 0 -- placeholder
    local units                 = args.units or "metric"
    local lang                  = args.lang or "en"
    local cnt                   = args.cnt or 5
    local icons_path            = args.icons_path or helpers.icons_dir .. "openweathermap/"
    local notification_preset   = args.notification_preset or {}
    local notification_text_fun = args.notification_text_fun or
                                  function (wn)
                                      local day = os.date("%a %d %H:%M", wn["dt"])
                                      local temp = math.floor(wn["main"]["temp"])
                                      local desc = wn["weather"][1]["description"]
                                      return string.format("<b>%s</b>: %s, %d°", day, desc, temp)
                                  end
    local weather_na_markup     = args.weather_na_markup or " N/A "
    local followtag             = args.followtag or false
    local showpopup             = args.showpopup or "on"
    local settings              = args.settings or function(_, _) end

    weather.widget:set_markup(weather_na_markup)
    weather.icon_path = icons_path .. "na.png"
    weather.icon = wibox.widget.imagebox(weather.icon_path)

    function weather.show(seconds)
        weather.hide()

        if followtag then
            notification_preset.screen = focused()
        end

        if not weather.notification_text then
            weather.update()
            weather.forecast_update()
        end

        weather.notification = naughty.notify {
            preset  = notification_preset,
            text    = weather.notification_text,
            icon    = weather.icon_path,
            timeout = type(seconds) == "number" and seconds or notification_preset.timeout
        }
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
        local uri = string.format(forecast_uri, lat, lon, APPID, cnt, units, lang)
        helpers.uri(uri, function(f)
            local forecast, _, err = json.decode(f, 1, nil)

            if not err and type(weather.forecast) == "table" and tonumber(forecast["cod"]) == 200 then
                weather.now.forecast = forecast
                weather.notification_text = ""
                for i = 1, forecast["cnt"], math.floor(forecast["cnt"] / cnt) do
                    weather.notification_text = weather.notification_text ..
                                                notification_text_fun(forecast["list"][i])
                    if i < forecast["cnt"] then
                        weather.notification_text = weather.notification_text .. "\n"
                    end
                end
            end
        end)
    end

    function weather.update()
        local uri = string.format(current_uri, lat, lon, APPID, units, lang)
        helpers.uri(uri, function(f)
            local current, _, err = json.decode(f, 1, nil)

            if not err and type(current) == "table" and tonumber(current["cod"]) == 200 then
                weather.now.current = current
                local sunrise = tonumber(current["sys"]["sunrise"])
                local sunset  = tonumber(current["sys"]["sunset"])
                local icon    = current["weather"][1]["icon"]
                local loc_now = os.time()
                local city    = current["name"]
                local temp    = current["main"]["temp"]

                if sunrise <= loc_now and loc_now <= sunset then
                    icon = string.gsub(icon, "n", "d")
                else
                    icon = string.gsub(icon, "d", "n")
                end

                weather.icon_path = icons_path .. icon .. ".png"
                weather.widget:set_markup(string.format(" %s %d° ", city, temp))
                settings(weather.widget, weather.now)
            else
                weather.icon_path = icons_path .. "na.png"
                weather.widget:set_markup(weather_na_markup)
            end

            weather.icon:set_image(weather.icon_path)
        end)
    end


    if showpopup == "on" then weather.attach(weather.widget) end

    weather.timer = helpers.newtimer("weather-" .. lat .. ":" .. lon, timeout, weather.update, false, true)
    weather.timer_forecast = helpers.newtimer("weather_forecast-" .. lat .. ":" .. lon, timeout, weather.forecast_update, false, true)

    return weather
end

return factory
