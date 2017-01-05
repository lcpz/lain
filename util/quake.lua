
--[[
                                                   
     Licensed under GNU General Public License v2  
      * (c) 2016, Luke Bonham                      
                                                   
--]]

local awful  = require("awful")
local capi   = { client = client,
                 mouse  = mouse,
                 screen = screen,
                 timer  = timer or require("gears.timer") }
local math   = { floor = math.floor }
local string = string

local pairs        = pairs
local setmetatable = setmetatable
local tostring     = tostring

-- Quake-like Dropdown application spawn
-- Original version: https://awesomewm.org/wiki/Drop-down_terminal#Another_solution
local quake = {}

-- If you have a rule like "awful.client.setslave" for your terminals,
-- ensure you use an exception for QuakeDD. Otherwise, you may
-- run into problems with focus.

function quake:display()
   -- First, we locate the client
   local client = nil
   local i = 0
   for c in awful.client.iterate(function (c)
       -- c.name may be changed!
       return c.instance == self.name
   end, nil, self.screen)
   do
       i = i + 1
       if i == 1 then
           client = c
       else
           -- Additional matching clients, let's remove the sticky bit
           -- which may persist between awesome restarts. We don't close
           -- them as they may be valuable. They will just turn into
           -- normal clients.
           c.sticky = false
           c.ontop = false
           c.above = false
       end
   end

   if not client and not self.visible then return end

   if not client then
       -- The client does not exist, we spawn it
       awful.util.spawn(string.format("%s %s %s", self.app,
                        string.format(self.argname, self.name), self.extra),
                        false, self.screen)
       self.notexist = true
       return
   end

   -- Resize
   awful.client.floating.set(client, true)
   client.border_width = self.border
   client.size_hints_honor = false
   if self.notexist then
       client:geometry(self.geometry)
       self.notexist = false
   end

   -- Not sticky and on top
   client.ontop = true
   client.above = true
   client.skip_taskbar = true
   client.sticky = false

   -- Toggle display
   if self.visible then
       client.hidden = false
       client:raise()
       self.last_tag = tostring(awful.tag.selected(self.screen))
       client:tags({awful.tag.selected(self.screen)})
       capi.client.focus = client
   else
       client.hidden = true
       local ctags = client:tags()
       for i, t in pairs(ctags) do
           ctags[i] = nil
       end
       client:tags(ctags)
   end

   return client
end

function quake:new(config)
   local conf = config or {}

   conf.app      = conf.app      or "xterm"    -- application to spawn
   conf.name     = conf.name     or "QuakeDD"  -- window name
   conf.argname  = conf.argname  or "-name %s" -- how to specify window name
   conf.extra    = conf.extra    or ""         -- extra arguments
   conf.visible  = conf.visible  or false      -- initially not visible
   conf.screen   = conf.screen   or capi.mouse.screen
   conf.border   = conf.border   or 1

   -- If width or height <= 1 this is a proportion of the workspace
   wibox_height = conf.wibox_height or 18       -- statusbar weight
   height       = conf.height       or 0.25     -- height
   width        = conf.width        or 1        -- width
   vert         = conf.vert         or "top"    -- top, bottom or center
   horiz        = conf.horiz        or "center" -- left, right or center

   -- Compute size
   local geom = capi.screen[conf.screen].workarea
   if width  <= 1 then width = math.floor(geom.width * width) end
   if height <= 1 then height = math.floor(geom.height * height) end
   local x, y
   if     horiz == "left"  then x = geom.x
   elseif horiz == "right" then x = geom.width + geom.x - width
   else   x = geom.x + (geom.width - width)/2 end
   if     vert == "top"    then y = geom.y
   elseif vert == "bottom" then y = geom.height + geom.y - height
   else   y = geom.y + (geom.height - height)/2 end
   conf.geometry = { x = x, y = y + wibox_height, width = width, height = height }

   local console = setmetatable(conf, { __index = quake })
   capi.client.connect_signal("manage", function(c)
       if c.instance == console.name and c.screen == console.screen then
           console:display()
       end
   end)
   capi.client.connect_signal("unmanage", function(c)
       if c.instance == console.name and c.screen == console.screen then
           console.visible = false
       end
    end)

   -- "Reattach" currently running quake application. This is in case awesome is restarted.
   local reattach = capi.timer { timeout = 0 }
   reattach:connect_signal("timeout", function()
       reattach:stop()
       console:display()
   end)
   reattach:start()

   return console
end

function quake:toggle()
    current_tag = awful.tag.selected(self.screen)
    if self.last_tag ~= tostring(current_tag) and self.visible then
        awful.client.movetotag(current_tag, self:display())
    else
        self.visible = not self.visible
        self:display()
    end
end

setmetatable(quake, { __call = function(_, ...) return quake:new(...) end })

return quake
