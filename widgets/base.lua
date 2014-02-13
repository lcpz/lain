
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2014, Luke Bonham                     
                                                  
--]]

local newtimer     = require("lain.helpers").newtimer
local wibox        = require("wibox")

local io           = io
local setmetatable = setmetatable

-- Basic template for simple widgets 
-- lain.widgets.base
local base = {}

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 5
    local cmd      = args.cmd or ""
    local settings = args.settings or function() end

    base.widget = wibox.widget.textbox('')

    function update()
        output = io.popen(cmd):read("*all")
        widget = base.widget
        settings()
    end

    newtimer(cmd, timeout, update)
    return base.widget
end

return setmetatable(base, { __call = function(_, ...) return worker(...) end })
