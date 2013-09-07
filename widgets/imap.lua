
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
                                                  
--]]

local markup       = require("lain.util.markup")
local helpers      = require("lain.helpers")

local awful        = require("awful")
local beautiful    = require("beautiful")
local naughty      = require("naughty")
local wibox        = require("wibox")

local io           = io
local tonumber     = tonumber
local string       = string

local setmetatable = setmetatable

-- Mail imap check
-- lain.widgets.imap
local imap = {} 

function worker(args)
    local args = args or {}

    local server = args.server
    local mail = args.mail
    local password = args.password

    local port = args.port or "993"
    local refresh_timeout = args.refresh_timeout or 60
    local header = args.header or " Mail "
    local header_color = args.header_color or beautiful.fg_normal or "#FFFFFF"
    local color_newmail = args.color_newmail or beautiful.fg_focus or "#FFFFFF"
    local color_nomail = args.color_nomail or beautiful.fg_normal or "#FFFFFF"
    local mail_encoding = args.mail_encoding or nil
    local maxlen = args.maxlen or 200
    local app = args.app or "mutt"
    local is_plain = args.is_plain or false
    local shadow = args.shadow or false

    helpers.set_map(mail, true)
    helpers.set_map(mail .. " count", "0")

    local checkmail = helpers.scripts_dir .. "checkmail"

    if not is_plain
    then
        local f = io.popen(password)
        password = f:read("*all"):gsub("\n", ""):gsub("\r", "")
        f:close()
    end

    local myimapcheck = wibox.widget.textbox()

    local myimapcheckupdate = function()
        function set_nomail()
            if shadow
            then
                myimapcheck:set_text('')
            else
                myimapcheck:set_markup(markup(color_nomail, " no mail "))
            end
        end

        conn = io.popen("ip link show")
        check_conn = conn:read("*all") 
        conn:close()

        if not check_conn:find("state UP") then
               set_nomail()
               return
        end

        to_execute = checkmail .. ' -s ' .. server ..
                     ' -u ' .. mail .. ' -p ' .. password
                     .. ' --port ' .. port

        if mail_encoding ~= nil
        then
            to_execute = to_execute .. ' --encoding '
                         .. mail_encoding
        end

        f = io.popen(to_execute)
        ws = f:read("*all")
        f:close()

        if ws:find("No new messages") ~= nil
        then
            helpers.set_map(mail, true)
            set_nomail()
        elseif ws:find("CheckMailError: invalid credentials") ~= nil
        then
            helpers.set_map(mail, true)
            myimapcheck.set_markup(markup(header_color, header) ..
                                   markup(color_newmail, "invalid credentials "))
        else
            mailcount = ws:match("%d") or "?"

            if helpers.get_map(mail .. " count") ~= mailcount and mailcount ~= "?"
            then
                helpers.set_map(mail, true)
                helpers.set_map(mail .. " count", mailcount)
            end

            myimapcheck:set_markup(markup(header_color, header) ..
                                   markup(color_newmail, mailcount) .. " ")

            if helpers.get_map(mail)
            then
                if mailcount == "?"
                -- May happens sometimes using keyrings or other password fetchers.
                -- Since this should be automatically fixed in short times, we threat
                -- this exception delaying the update to the next timeout.
                then
                    set_nomail()
                    return
                elseif tonumber(mailcount) >= 1
                then
                    notify_title = ws:match(mail .. " has %d new message.?")
                    ws = ws:gsub(notify_title, "", 1):gsub("\n", "", 2)

                    ws = ws:gsub("--Content.%S+.-\n", "")
                    ws = ws:gsub("--%d+.-\n", "")

                    if string.len(ws) > maxlen
                    then
                        ws = ws:sub(1, maxlen) .. "[...]"
                    end

                    notify_title = notify_title:gsub("\n", "")
                end

                naughty.notify({ title = notify_title,
                                 fg = color_newmail,
                                 text = ws,
                                 icon = beautiful.lain_mail_notify or
                                        helpers.icons_dir .. "mail.png",
                                 timeout = 8,
                                 position = "top_left" })

                helpers.set_map(mail, false)
            end
        end
    end

    local myimapchecktimer = timer({ timeout = refresh_timeout })
    myimapchecktimer:connect_signal("timeout", myimapcheckupdate)
    myimapchecktimer:start()
    myimapcheck:buttons(awful.util.table.join(
        awful.button({}, 0,

            function()
                helpers.run_in_terminal(app)
            end)
    ))

    return myimapcheck
end

return setmetatable(imap, { __call = function(_, ...) return worker(...) end })
