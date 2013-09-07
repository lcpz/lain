
--[[
                                               
     Yahoo's Awesome (WM) Weather Notification 
                                               
     Licensed under WTFPL v2                   
      * (c) 2013, Luke Bonham                  
                                               
--]]

local markup       = require("lain.util.markup")

local beautiful    = require("beautiful")
local naughty      = require("naughty")
local wibox        = require("wibox")

local debug        = { getinfo = debug.getinfo }
local io           = io
local os           = { date    = os.date,
                       getenv  = os.getenv }
local string       = { find    = string.find,
                       match   = string.match,
                       gsub    = string.gsub,
                       sub     = string.sub }
local tonumber     = tonumber

local setmetatable = setmetatable

-- yawn integration
-- https://github.com/copycat-killer/yawn
-- lain.widgets.yawn
local yawn =
{
    units    = "",
    forecast = "",
    icon     = wibox.widget.imagebox(),
    widget   = wibox.widget.textbox()
}

local project_path       = debug.getinfo(1, 'S').source:match[[^@(.*/).*$]]
local localizations_path = project_path .. 'localizations/'
local icon_path          = project_path .. 'icons/'
local api_url            = 'http://weather.yahooapis.com/forecastrss'
local units_set          = '?u=c&w=' -- Default is Celsius
local language           = string.match(os.getenv("LANG"), "(%S*$*)[.]")
local weather_data       = nil
local notification       = nil
local city_id            = nil
local sky                = nil
local settings           = {}
local update_timer       = nil

local function fetch_weather(args)
    local toshow = args.toshow or "forecast"
    local spr = args.spr or " "
    local footer = args.footer or ""

    local url = api_url .. units_set .. city_id
    local f = io.popen("curl --connect-timeout 1 -fsm 2 '"
                       .. url .. "'" )
    local text = f:read("*all")
    io.close(f)

    -- In case of no connection or invalid city ID
    -- widgets won't display
    if text == "" or text:match("City not found")
    then
        sky = icon_path .. "na.png"
        if text == "" then
            weather_data = "Service not available at the moment."
            return "N/A"
        else
            weather_data = "City not found!\n" ..
                           "Are you sure " .. city_id ..
                           " is your Yahoo city ID?"
            return "?"
        end
    end

    -- Processing raw data
    weather_data = text:gsub("<.->", "")
    weather_data = weather_data:match("Current Conditions:.-Full")
    weather_data = weather_data:gsub("Current Conditions:.-\n", "Now: ")
    weather_data = weather_data:gsub("Forecast:.-\n", "")
    weather_data = weather_data:gsub("\nFull", "")
    weather_data = weather_data:gsub("[\n]$", "")
    weather_data = weather_data:gsub(" [-] " , ": ")
    weather_data = weather_data:gsub("[.]", ",")
    weather_data = weather_data:gsub("High: ", "")
    weather_data = weather_data:gsub(" Low: ", " - ")

    -- Getting info for text widget
    local now      = weather_data:sub(weather_data:find("Now:")+5,
                     weather_data:find("\n")-1)
    local forecast = now:sub(1, now:find(",")-1)
    local units    = now:sub(now:find(",")+2, -2)

    -- Day/Night icon change
    local hour = tonumber(os.date("%H"))
    sky = icon_path

    if forecast == "Clear"         or
       forecast == "Fair"          or
       forecast == "Partly Cloudy" or
       forecast == "Mostly Cloudy"
       then
           if hour >= 6 and hour <= 18
           then
               sky = sky .. "Day"
           else
               sky = sky .. "Night"
           end
    end

    sky = sky  .. forecast:gsub(" ", ""):gsub("/", "") .. ".png"

    -- In case there's no defined icon for current forecast
    f = io.popen(sky)
    if f == nil then
        sky = icon_path .. "na.png"
    else
        io.close(f)
    end

    -- Localization
    local f = io.open(localizations_path .. language, "r")
    if language:find("en_") == nil and f ~= nil
    then
        io.close(f)
        for line in io.lines(localizations_path .. language)
        do
            word = string.sub(line, 1, line:find("|")-1)
            translation = string.sub(line, line:find("|")+1)
            weather_data = string.gsub(weather_data, word, translation)
        end
    end

    -- Finally setting infos
    forecast = weather_data:match(": %S+"):gsub(": ", ""):gsub(",", "")
    yawn.forecast = markup(yawn.forecast_color, markup.font(beautiful.font, forecast))
    yawn.units = markup(yawn.units_color, markup.font(beautiful.font, units))
    yawn.icon:set_image(sky)

    if toshow == "forecast" then
        return yawn.forecast
    elseif toshow == "units" then
        return yawn.units
    else -- "both"
        return yawn.forecast .. spr
               .. yawn.units .. footer
    end
end

function yawn.hide()
    if notification ~= nil then
        naughty.destroy(notification)
        notification = nil
    end
end

function yawn.show(t_out)
    if yawn.widget._layout.text == "?"
    then
        if update_timer ~= nil
        then
            update_timer:emit_signal("timeout")
        else
            fetch_weather(settings)
        end
    end

    yawn.hide()

    notification = naughty.notify({
        text = weather_data,
        icon = sky,
        timeout = t_out,
        fg = yawn.notification_color
    })
end

function yawn.register(id, args)
    local args = args or {}

    settings = { args.toshow, args.spr, args.footer }

    yawn.units_color        = args.units_color or
                              beautiful.fg_normal or "#FFFFFF"
    yawn.forecast_color     = args.forecast_color or
                              yawn.units_color
    yawn.notification_color = args.notification_color or
                              beautiful.fg_focus or "#FFFFFF"

    if args.u == "f" then units_set = '?u=f&w=' end

    city_id = id

    update_timer = timer({ timeout = 600 }) -- 10 mins
    update_timer:connect_signal("timeout", function()
        yawn.widget:set_markup(fetch_weather(settings))
    end)
    update_timer:start()
    update_timer:emit_signal("timeout")

    yawn.icon:connect_signal("mouse::enter", function()
        yawn.show(0)
    end)
    yawn.icon:connect_signal("mouse::leave", function()
        yawn.hide()
    end)
end

function yawn.attach(widget, id, args)
    yawn.register(id, args)

    widget:connect_signal("mouse::enter", function()
        yawn.show(0)
    end)

    widget:connect_signal("mouse::leave", function()
        yawn.hide()
    end)
end

-- }}}

return setmetatable(yawn, { __call = function(_, ...) return yawn.register(...) end })
