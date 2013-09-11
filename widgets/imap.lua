
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
                                                  
--]]

local helpers      = require("lain.helpers")

local naughty      = require("naughty")
local wibox        = require("wibox")

local io           = { popen = io.popen }
local tonumber     = tonumber
local string       = { len    = string.len,
                       format = string.format }

local setmetatable = setmetatable

-- Mail IMAP check
-- lain.widgets.imap
local imap = {}

local function worker(args)
    local args     = args or {}

    local server   = args.server
    local mail     = args.mail
    local password = args.password

    local port     = args.port or "993"
    local timeout  = args.timeout or 60
    local encoding = args.encoding or nil
    local maxlen   = args.maxlen or 200
    local is_plain = args.is_plain or false
    local settings = args.settings or function() end

    local checkmail = helpers.scripts_dir .. "checkmail"

    helpers.set_map(mail, true)
    helpers.set_map(mail .. " count", "0")

    if not is_plain
    then
        if not imap.stored
        then
            local f = io.popen(password)
            password = f:read("*all"):gsub("\n", ""):gsub("\r", "")
            f:close()
            imap.stored = password
        else
            password = imap.stored
        end
    end

    imap.widget = wibox.widget.textbox('')

    notification_preset = {
        icon     = helpers.icons_dir .. "mail.png",
        timeout  = 8,
        position = "top_left"
    }

    function imap.update()
        to_execute = string.format("%s -s %s -u %s -p %s --port %s",
                     checkmail, server, mail, password, port) 

        if encoding ~= nil
        then
            to_execute = string.format("%s --encoding %s",
                         to_execute, encoding)
        end

        f = io.popen(to_execute)
        ws = f:read("*all")
        f:close()

        mailcount = "0"

        if ws:find("No new messages") ~= nil
        then
            helpers.set_map(mail, true)
        elseif ws:find("CheckMailError: invalid credentials") ~= nil
        then
            helpers.set_map(mail, true)
            mailcount = "invalid credentials"
        else
            mailcount = ws:match("%d") or "0"
            if helpers.get_map(mail .. " count") ~= mailcount and mailcount ~= "0"
            then
                helpers.set_map(mail, true)
                helpers.set_map(mail .. " count", mailcount)
            end
        end

        widget = imap.widget
        settings()

        if helpers.get_map(mail) and tonumber(mailcount) >= 1
        then
            notify_title = ws:match(mail .. " has %d new message.?")
            ws = ws:gsub(notify_title, "", 1):gsub("\n", "", 2)

            -- trying to remove useless infos
            ws = ws:gsub("--Content.%S+.-\n", "")
            ws = ws:gsub("--%d+.-\n", "")

            if string.len(ws) > maxlen
            then
                ws = ws:sub(1, maxlen) .. "[...]"
            end

            notify_title = notify_title:gsub("\n", "")

            naughty.notify({
                preset = notification_preset,
                title = notify_title,
                text = ws
            })

            helpers.set_map(mail, false)
        end
    end

    helpers.newtimer(mail, timeout, imap.update, true)

    return imap.widget
end

return setmetatable(imap, { __call = function(_, ...) return worker(...) end })
