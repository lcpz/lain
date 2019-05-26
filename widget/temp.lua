--[[

     Licensed under GNU General Public License v2
      * (c) 2013, Luca CPZ

--]]

local helpers  = require("lain.helpers")
local wibox    = require("wibox")
local open     = io.open
local tonumber = tonumber

-- coretemp
-- lain.widget.temp

local function factory(args)
    local temp     = { widget = wibox.widget.textbox() }
    local args     = args or {}
    local timeout  = args.timeout or 2
    local settings = args.settings or function() end

    local tempfile
    if args.tempfile then
      tempfile = args.tempfile
    else
      local base_dir, f, content
      for filename in io.popen('ls /sys/class/thermal/'):lines() do
        base_dir = "/sys/class/thermal/" .. filename
        f = io.open(base_dir .. "/type")
        content = f:read("*all"):gsub("^%s*(.-)%s*$", "%1")
        f:close()
        if content == "x86_pkg_temp" then
          tempfile = base_dir .. "/temp"
          break
        end
      end
    end

    function temp.update()
        local f = open(tempfile)
        if f then
            coretemp_now = tonumber(f:read("*all")) / 1000
            f:close()
        else
            coretemp_now = "N/A"
        end

        widget = temp.widget
        settings()
    end

    helpers.newtimer("coretemp", timeout, temp.update)

    return temp
end

return factory
