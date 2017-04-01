--[[
                                                   
     Licensed under GNU General Public License v2  
      * (c) 2015, aajjbb <http://github.com/aajjbb>
                                                   
--]]

local helpers = require("lain.helpers")
local async   = require("lain.asyncshell")

local escape_f = require("awful.util").escape
local naughty  = require("naughty")
local wibox    = require("wibox")

local io     = { popen   = io.popen }
local os     = { execute = os.execute,
                 getenv  = os.getenv }
local string = { format  = string.format,
                 gmatch  = string.gmatch }

local setmetatable = setmetatable

local cmus = {}

local function worker(args)
    local args        = args or {}
    local timeout     = args.timeout or 2
    local music_dir   = args.music_dir or os.getenv("HOME") .. "/Music"
    local cover_size  = args.cover_size or 100
    local default_art = args.default_art or ""
    local settings    = args.settings or function() end

    cmus.widget = wibox.widget.textbox('')

    cmus_notification_preset = {
        title   = "Now playing",
        timeout = 6
    }

    helpers.set_map("current cmus track", nil)

    function cmus.update()
	   -- cmus-remote -Q will produce output like:
	   -- tag artist Kiko Loureiro
	   -- tag album Fullblast

        async.request("cmus-remote -Q", function(f)
            cmus_now = {
                artist  = "N/A",
                title   = "N/A",
                album   = "N/A",
				state   = "N/A",
            }

			for line in f:lines() do
			   for k, v in string.gmatch(line, "(%w+)%s(%w+)") do
				  if k == "status" then
					 cmus_now.state = escape_f(v)
				  end
			   end
			   
			   for k, v, p in string.gmatch(line, "(%w+)%s(%w+)%s([0-9A-Za-z%s]+)") do
				  if k == "tag" then
					 if v == "artist" then
						cmus_now.artist = escape_f(p)
					 elseif v == "title" then
						cmus_now.title = escape_f(p)
					 elseif v == "album" then
						cmus_now.album = escape_f(p)				  
					 end
				  end
			   end
			end
			   
            widget = cmus.widget
            settings()
		end)
    end
	
    helpers.newtimer("cmus", timeout, cmus.update)

    return setmetatable(cmus, { __index = cmus.widget })
end

return setmetatable(cmus, { __call = function(_, ...) return worker(...) end })
