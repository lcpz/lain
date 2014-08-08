
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2014, Luke Bonham                     
                                                  
--]]

local newtimer     = require("lain.helpers").newtimer
local async        = require("lain.asyncshell")
local wibox        = require("wibox")

local setmetatable = setmetatable

-- Basic template for custom widgets 
-- Asynchronous version
-- lain.widgets.abase

local function worker(args)
    local abase    = {}
    local args     = args or {}
    local timeout  = args.timeout or 5
    local cmd      = args.cmd or ""
    local settings = args.settings or function() end

    abase.widget = wibox.widget.textbox('')

    function abase.update()
        async.request(cmd, function(f)
            output = f:read("*a")
            f:close()
            widget = abase.widget
            settings()
        end)
    end

    newtimer(cmd, timeout, abase.update)

    return setmetatable(abase, { __index = abase.widget })
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
