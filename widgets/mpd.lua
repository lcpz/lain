
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
      * (c) 2010, Adrian C. <anrxc@sysphere.org>  
                                                  
--]]

local markup       = require("lain.util.markup")
local helpers      = require("lain.helpers")

local awful        = require("awful")
local beautiful    = require("beautiful")
local naughty      = require("naughty")
local wibox        = require("wibox")

local io           = io
local os           = { execute  = os.execute,
                       getenv   = os.getenv }
local string       = { gmatch   = string.gmatch }

local setmetatable = setmetatable

-- MPD infos
-- lain.widgets.mpd
local mpd = { id = nil }

function worker(args)
    local args = args or {}
    local password = args.password or ""
    local host = args.host or "127.0.0.1"
    local port = args.port or "6600"
    local music_dir = args.music_dir or os.getenv("HOME") .. "/Music"
    local refresh_timeout = args.refresh_timeout or 1
    local header_color = args.header_color or beautiful.fg_normal or "#FFFFFF"
    local color = args.color or beautiful.fg_focus or "#FFFFFF"
    local spr = args.spr or " "
    local app = args.app or "ncmpcpp"
    local shadow = args.shadow or false

    local mpdcover = helpers.scripts_dir .. "mpdcover"
    local mpdh = "telnet://"..host..":"..port
    local echo = "echo 'password "..password.."\nstatus\ncurrentsong\nclose'"

    local mympd = wibox.widget.textbox()

    helpers.set_map("current mpd track", nil)

    local mympdupdate = function()
        local function set_nompd()
            if shadow
            then
                mympd:set_text('')
            else
                mympd:set_markup(markup(header_color, " mpd "), markup(color , "off "))
            end
        end

        local mpd_state  = {
            ["{state}"]  = "N/A",
            ["{file}"]   = "N/A",
            ["{Artist}"] = "N/A",
            ["{Title}"]  = "N/A",
            ["{Album}"]  = "N/A",
            ["{Date}"]   = "N/A"
        }

        -- Get data from MPD server
        local f = io.popen(echo .. " | curl --connect-timeout 1 -fsm 3 " .. mpdh)

        for line in f:lines() do
            for k, v in string.gmatch(line, "([%w]+):[%s](.*)$") do
                if     k == "state"  then mpd_state["{"..k.."}"] = v
                elseif k == "file"   then mpd_state["{"..k.."}"] = v
                elseif k == "Artist" then mpd_state["{"..k.."}"] = awful.util.escape(v)
                elseif k == "Title"  then mpd_state["{"..k.."}"] = awful.util.escape(v)
                elseif k == "Album"  then mpd_state["{"..k.."}"] = awful.util.escape(v)
                elseif k == "Date"   then mpd_state["{"..k.."}"] = awful.util.escape(v)
                end
            end
        end

        f:close()

        if mpd_state["{state}"] == "play"
        then
            if mpd_state["{Title}"] ~= helpers.get_map("current mpd track")
            then
                helpers.set_map("current mpd track", mpd_state["{Title}"])
                os.execute(mpdcover .. " '" .. music_dir .. "' '"
                           .. mpd_state["{file}"] .. "'")
                mpd.id = naughty.notify({
                    title = "Now playing",
                    text = mpd_state["{Artist}"] .. " ("   ..
                           mpd_state["{Album}"]  .. ") - " ..
                           mpd_state["{Date}"]   .. "\n"   ..
                           mpd_state["{Title}"],
                    icon = "/tmp/mpdcover.png",
                    fg = color,
                    timeout = 6, 
                    replaces_id = mpd.id
                }).id
            end
            mympd:set_markup(markup(header_color, " " .. mpd_state["{Artist}"])
                             .. spr ..
                             markup(color, mpd_state["{Title}"] .. " "))
        elseif mpd_state["{state}"] == "pause"
        then
            mympd:set_markup(markup(header_color, " mpd")
                             .. spr ..
                             markup(color, "paused "))
        else
            helpers.set_map("current mpd track", nil)
		        set_nompd()
	      end
    end

    local mympdtimer = timer({ timeout = refresh_timeout })
    mympdtimer:connect_signal("timeout", mympdupdate)
    mympdtimer:start()
    mympdtimer:emit_signal("timeout")

    mympd:buttons(awful.util.table.join(
        awful.button({}, 0,
            function()
                helpers.run_in_terminal(app)
            end)
    ))

    local mpd_out = { widget = mympd, notify = mympdupdate }

    return setmetatable(mpd_out, { __index = mpd_out.widget })
end

return setmetatable(mpd, { __call = function(_, ...) return worker(...) end })
