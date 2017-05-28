local newtimer     = require("lain.helpers").newtimer

local wibox        = require("wibox")

local io           = { open = io.open }
local tonumber     = tonumber

local setmetatable = setmetatable

-- applesmc
-- lain.widgets.temp
local applesmc = {}

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 5
    local fan1file = args.fan1 or "/sys/devices/platform/applesmc.768/fan1_input"
    local fan2file = args.fan2 or "/sys/devices/platform/applesmc.768/fan2_input"
    local settings = args.settings or function() end 

    applesmc.widget = wibox.widget.textbox('')

    function update()
        local f1 = io.open(fan1file)
        if f1 ~= nil 
        then
            fan1_now = tonumber(f1:read("*a"))
            f1:close()
        else
            fan1_now = "N/A"
        end 

        local f2 = io.open(fan1file)
        if f2 ~= nil 
        then
            fan2_now = tonumber(f2:read("*a"))
            f2:close()
        else
            fan2_now = "N/A"
        end 

        widget = applesmc.widget
        settings()
    end 

    newtimer("applesmc", timeout, update)
    return applesmc.widget
end

return setmetatable(applesmc, { __call = function(_, ...) return worker(...) end })

