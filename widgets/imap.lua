
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
                                                  
--]]

local helpers      = require("lain.helpers")
local async        = require("lain.asyncshell")

local naughty      = require("naughty")
local wibox        = require("wibox")

local string       = { format = string.format,
                       gsub   = string.gsub }
local tonumber     = tonumber

local setmetatable = setmetatable

-- Mail IMAP check
-- lain.widgets.imap

local function worker(args)
    local imap     = {}
    local args     = args or {}

    local server   = args.server
    local mail     = args.mail
    local password = args.password

    local port     = args.port or 993
    local timeout  = args.timeout or 60
    local is_plain = args.is_plain or false
    local settings = args.settings or function() end

    local head_command  = "curl --connect-timeout 3 -fsm 3"
    local request = "-X 'SEARCH (UNSEEN)'"

    helpers.set_map(mail, 0)

    if not is_plain
    then
        local f = io.popen(password)
        password = f:read("*a"):gsub("\n", "")
        f:close()
    end

    imap.widget = wibox.widget.textbox('')

    function update()
        mail_notification_preset = {
            icon     = helpers.icons_dir .. "mail.png",
            position = "top_left"
        }

        curl = string.format("%s --url imaps://%s:%s/INBOX -u %s:%q %s -k",
               head_command, server, port, mail, password, request)

        async.request(curl, function(f)
            ws = f:read("*a")
            f:close()

            _, mailcount = string.gsub(ws, "%d+", "")
            _ = nil

            widget = imap.widget
            settings()

            if mailcount >= 1 and mailcount > helpers.get_map(mail)
            then
                if mailcount == 1 then
                    nt = mail .. " has one new message"
                else
                    nt = mail .. " has <b>" .. mailcount .. "</b> new messages"
                end
                naughty.notify({
                    preset = mail_notification_preset,
                    text = nt,
                })
            end

            helpers.set_map(mail, mailcount)
        end)

    end

    helpers.newtimer(mail, timeout, update, true)

    return setmetatable(imap, { __index = imap.widget })
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
