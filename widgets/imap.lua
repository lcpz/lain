
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
                                                  
--]]

local helpers      = require("lain.helpers")

local naughty      = require("naughty")
local wibox        = require("wibox")

local string       = { format = string.format,
                       gsub   = string.gsub }
local tonumber     = tonumber

local setmetatable = setmetatable

-- Mail IMAP check
-- lain.widgets.imap

local function worker(args                           )
    local imap      = helpers.make_widget_textbox()
    local args      = args or {}
    local server    = args.server
    local mail      = args.mail
    local password  = args.password
    local port      = args.port or 993
    local timeout   = args.timeout or 60
    local is_plain  = args.is_plain or false
    local followtag = args.followtag or false
    local settings  = args.settings or function() end

    local head_command = "curl --connect-timeout 3 -fsm 3"
    local request = "-X 'SEARCH (UNSEEN)'"

    helpers.set_map(mail, 0)

    if not is_plain then
        helpers.async(password, function(f) password = f:gsub("\n", "") end)
    end

    function update()
        mail_notification_preset = {
            icon     = helpers.icons_dir .. "mail.png",
            position = "top_left"
        }

        if followtag then
            mail_notification_preset.screen = awful.screen.focused()
        end

        curl = string.format("%s --url imaps://%s:%s/INBOX -u %s:%q %s -k",
               head_command, server, port, mail, password, request)

        helpers.async(curl, function(f)
            _, mailcount = string.gsub(f, "%d+", "")

            widget = imap.widget
            settings()

            if mailcount >= 1 and mailcount > helpers.get_map(mail) then
                if mailcount == 1 then
                    nt = mail .. " has one new message"
                else
                    nt = mail .. " has <b>" .. mailcount .. "</b> new messages"
                end
                naughty.notify({ preset = mail_notification_preset, text = nt })
            end

            helpers.set_map(mail, mailcount)
        end)

    end

    helpers.newtimer(mail, timeout, update)

    return setmetatable(imap, { __index = imap.widget })
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
