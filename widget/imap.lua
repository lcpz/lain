--[[

     Licensed under GNU General Public License v2
      * (c) 2013, Luca CPZ

--]]

local helpers  = require("lain.helpers")
local naughty  = require("naughty")
local wibox    = require("wibox")
local awful    = require("awful")
local string   = { format = string.format,
                   gsub   = string.gsub }
local type     = type
local tonumber = tonumber

-- Mail IMAP check
-- lain.widget.imap

local function factory(args)
    local imap      = { widget = wibox.widget.textbox() }
    local args      = args or {}
    local server    = args.server
    local mail      = args.mail
    local password  = args.password
    local port      = args.port or 993
    local timeout   = args.timeout or 60
    local is_plain  = args.is_plain or false
    local followtag = args.followtag or false
    local notify    = args.notify or "on"
    local settings  = args.settings or function() end

    local head_command = "curl --connect-timeout 3 -fsm 3"
    local request = "-X 'SEARCH (UNSEEN)'"

    if not server or not mail or not password then return end

    helpers.set_map(mail, 0)

    if not is_plain then
        if type(password) == "string" or type(password) == "table" then
            helpers.async(password, function(f) password = f:gsub("\n", "") end)
        elseif type(password) == "function" then
            local p = password()
        end
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

            if notify == "on" and mailcount >= 1 and mailcount > helpers.get_map(mail) then
                if mailcount == 1 then
                    nt = mail .. " has one new message"
                else
                    nt = mail .. " has <b>" .. mailcount .. "</b> new messages"
                end
                naughty.notify { preset = mail_notification_preset, text = nt }
            end

            helpers.set_map(mail, mailcount)
        end)

    end

    imap.timer = helpers.newtimer(mail, timeout, update, true, true)

    return imap
end

return factory
