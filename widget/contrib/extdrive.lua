--[[

    Licensed under GNU General Public License v2
    * (c) 2018, Bill Ayala

--]]

local async    = require("lain.helpers").async
local newtimer = require("lain.helpers").newtimer
local textbox  = require("wibox.widget").textbox
local os       = { execute = os.execute }

-- External drive presence indicator
-- lain.widget.contrib.extdrive

local function factory(args)
    local extdrive = { widget = textbox() }
    local args     = args or {}
    local timeout  = args.timeout or 5
    local drives   = args.drives or (args.drive and {args.drive}) or {"/dev/sdb1"}
    local settings = args.settings or function() end

    extdrive_now = {}
    extdrive_now.n_present    = {}
    extdrive_now.n_mounted    = {}
    extdrive_now.n_mountpoint = {}

    for i = 1, #drives do
        extdrive_now.n_present[i]    = false
        extdrive_now.n_mounted[i]    = false
        extdrive_now.n_mountpoint[i] = "N/A"
    end

    function extdrive.update()
        for i, drive in ipairs(drives) do
            async("findmnt -n -o TARGET " .. drive, function(mountpoint, exit_code)
                if exit_code == 0 then
                    extdrive_now.n_present[i]    = true
                    extdrive_now.n_mounted[i]    = true
                    extdrive_now.n_mountpoint[i] = mountpoint
                else
                    if os.execute("ls " .. drive) == 0 then
                        extdrive_now.n_present[i] = true
                    else
                        extdrive_now.n_present[i] = false
                    end

                    extdrive_now.n_mounted[i]    = false
                    extdrive_now.n_mountpoint[i] = "N/A"
                end
            end)
	    end

        widget = extdrive.widget
        settings()
    end

    newtimer("drives", timeout, extdrive.update)

    return extdrive
end

return factory
