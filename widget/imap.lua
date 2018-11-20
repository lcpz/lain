--[[

     Licensed under GNU General Public License v2
      * (c) 2013, Luca CPZ

--]]

local helpers  = require("lain.helpers")
local naughty  = require("naughty")
local wibox    = require("wibox")
local awful    = require("awful")
local string   = string
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
    local request = "-X 'STATUS INBOX (MESSAGES RECENT UNSEEN)'"

    if not server or not mail or not password then return end

    helpers.set_map(mail, 0)

    if not is_plain then
        if type(password) == "string" or type(password) == "table" then
            helpers.async(password, function(f) password = f:gsub("\n", "") end)
        elseif type(password) == "function" then
            imap.functimer = helpers.newtimer(mail .. "-pass", timeout/2, function() end, true, true)
            helpers.newtimer(
                mail .. "-pass",
                timeout/2,
                function()
                    local pass, try_again = password()
                    if not try_again then
                        imap.functimer:stop()
                        password = pass or ""
                    end
                end,
                false,
                true)
        end
    end

    function update()
        if type(password) ~= "string" then return end
        mail_notification_preset = {
            icon     = helpers.icons_dir .. "mail.png",
            position = "top_left"
        }

        if followtag then
            mail_notification_preset.screen = awful.screen.focused()
        end
        local curl = string.format("%s --url imaps://%s:%s/INBOX -u %s:'%s' %s -k",
                     head_command, server, port, mail, password, request)

        helpers.async(curl, function(f)
            local messages = 0
            local recent = 0
            local unseen = 0
            for s, d in f:gmatch("(%w+)%s+(%d+)") do
                if s == "RECENT" then recent = tonumber(d) end
                if s == "UNSEEN" then unseen = tonumber(d) end
                if s == "MESSAGES" then messages = tonumber(d) end
            end
            mailcount = unseen -- for settings compatability
            widget = imap.widget
            settings()

            if notify == "on" and mailcount and mailcount >= 1 and mailcount > helpers.get_map(mail) then
                local nt = mail .. " has <b>" .. mailcount .. "</b> new message"
                if mailcount >= 1 then nt = nt .. "s" end
                naughty.notify { preset = mail_notification_preset, text = nt }
            end

            helpers.set_map(mail, mailcount)
        end)

    end

    imap.timer = helpers.newtimer(mail, timeout, update, true, true)

    return imap
end

return factory
