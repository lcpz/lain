
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]

local awful        = require("awful")
local wibox        = require("wibox")
local helpers      = require("lain.helpers")
local io           = { popen  = io.popen }
local os           = { getenv = os.getenv }
local string       = { format = string.format,
                       match  = string.match }
local setmetatable = setmetatable

-- Maildir check (synchronous)
-- lain.widgets.maildir
local maildir = {}

local function worker(args)
    local args         = args or {}
    local timeout      = args.timeout or 60
    local mailpath     = args.mailpath or os.getenv("HOME") .. "/Mail"
    local ignore_boxes = args.ignore_boxes or {}
    local settings     = args.settings or function() end
    local ext_mail_cmd = args.external_mail_cmd

    maildir.widget = wibox.widget.textbox()

    function maildir.update()
        if ext_mail_cmd then awful.spawn(ext_mail_cmd) end

        -- Find pathes to mailboxes.
        local p = io.popen(string.format("find %s -mindepth 1 -maxdepth 2 -type d -not -name .git", mailpath))
        local boxes = {}
        repeat
            line = p:read("*l")
            if line then
                -- Find all files in the "new" subdirectory. For each
                -- file, print a single character (no newline). Don't
                -- match files that begin with a dot.
                -- Afterwards the length of this string is the number of
                -- new mails in that box.
                local mailstring = helpers.read_pipe(string.format("find %s /new -mindepth 1 -type f -not -name '.*' -printf a", line))

                -- Strip off leading mailpath.
                local box      = string.match(line, mailpath .. "/(.*)")
                local nummails = #mailstring

                if nummails > 0 then
                    boxes[box] = nummails
                end
            end
        until not line
        p:close()

        local newmail = "no mail"
        local total = 0

        for box, number in helpers.spairs(boxes) do
            -- Add this box only if it's not to be ignored.
            if not helpers.element_in_table(box, ignore_boxes) then
                total = total + number
                if newmail == "no mail" then
                    newmail = string.format("%s(%s)", box, number)
                else
                    newmail = string.format("%s, %s(%s)", newmail, box, number)
                end
            end
        end

        widget = maildir.widget
        settings()
    end

    maildir.timer = helpers.newtimer(mailpath, timeout, maildir.update, true, true)

    return setmetatable(maildir, { __index = maildir.widget })
end

return setmetatable(maildir, { __call = function(_, ...) return worker(...) end })
