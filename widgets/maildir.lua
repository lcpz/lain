
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local markup          = require("lain.util.markup")
local run_in_terminal = require("lain.helpers").run_in_terminal

local awful           = require("awful")
local beautiful       = require("beautiful")
local wibox           = require("wibox")

local io              = io
local os              = { getenv = os.getenv }
local pairs           = pairs
local string          = { len    = string.len,
                          match  = string.match }
local table           = { sort   = table.sort }

local setmetatable    = setmetatable

-- Maildir check
-- lain.widgets.maildir
local maildir = {}

function worker(args)
    local args = args or {}
    local mailpath = args.mailpath or os.getenv("HOME") .. "/Mail"
    local ignore_boxes = args.ignore_boxes or {}
    local refresh_timeout = args.refresh_timeout or 60
    local header = args.header or " Mail "
    local header_color = args.header_color or beautiful.fg_normal or "#FFFFFF"
    local color_newmail = args.color_newmail or beautiful.fg_focus or "#FFFFFF"
    local color_nomail = args.color_nomail or beautiful.fg_normal or "#FFFFFF"
    local app = args.app or "mutt"
    local shadow = args.shadow or false

    local mymailcheck = wibox.widget.textbox()
    local mymailcheckupdate = function()
        -- Find pathes to mailboxes.
        local p = io.popen("find " .. mailpath ..
                           " -mindepth 1 -maxdepth 1 -type d" ..
                           " -not -name .git")
        local boxes = {}
        local line = ""
        repeat
            line = p:read("*l")
            if line ~= nil
            then
                -- Find all files in the "new" subdirectory. For each
                -- file, print a single character (no newline). Don't
                -- match files that begin with a dot.
                -- Afterwards the length of this string is the number of
                -- new mails in that box.
                local np = io.popen("find " .. line ..
                                    "/new -mindepth 1 -type f " ..
                                    "-not -name '.*' -printf a")
                local mailstring = np:read("*all")

                -- Strip off leading mailpath.
                local box = string.match(line, mailpath .. "/*([^/]+)")
                local nummails = string.len(mailstring)
                if nummails > 0
                then
                    boxes[box] = nummails
                end
            end
        until line == nil

        table.sort(boxes)

        local newmail = ""
        local count = 0
        for box, number in pairs(boxes)
        do
            count = count + 1
            -- Add this box only if it's not to be ignored.
            if not util.element_in_table(box, ignore_boxes)
            then
                if newmail == ""
                then
                    newmail = box .. "(" .. number .. ")"
                else
                    newmail = newmail .. ", " ..
                              box .. "(" .. number .. ")"
                end
            end
        end

        if count == 1 then
            -- it will be only executed once
            for box, number in pairs(boxes)
            do  -- it's useless to show only INBOX(x)
                if box == "INBOX" then newmail = number end
            end
        end

        if newmail == ""
        then
            if shadow
            then
                mymailcheck:set_text('')
            else
                myimapcheck:set_markup(markup(color_nomail, " no mail "))
            end
        else
            myimapcheck:set_markup(" " .. markup(header_color, header) ..
                                   markup(color_newmail, newmail) .. " ")
        end
    end

    local mymailchecktimer = timer({ timeout = refresh_timeout })
    mymailchecktimer:connect_signal("timeout", mymailcheckupdate)
    mymailchecktimer:start()
    mymailcheck:buttons(awful.util.table.join(
        awful.button({}, 0,
            function()
                run_in_terminal(app)
            end)
    ))

    return mymailcheck
end

return setmetatable(maildir, { __call = function(_, ...) return worker(...) end })
