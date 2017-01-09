
--[[
                                                   
     Lain                                          
     Layouts, widgets and utilities for Awesome WM 
                                                   
     Utilities section                             
                                                   
     Licensed under GNU General Public License v2  
      * (c) 2013,      Luke Bonham                 
      * (c) 2010-2012, Peter Hofmann               
                                                   
--]]

local awful        = require("awful")
local beautiful    = require("beautiful")
local math         = { sqrt = math.sqrt }
local mouse        = mouse
local pairs        = pairs
local string       = { gsub = string.gsub }
local client       = client
local screen       = screen
local tonumber     = tonumber

local wrequire     = require("lain.helpers").wrequire
local setmetatable = setmetatable

-- Lain utilities submodule
-- lain.util
local util = { _NAME = "lain.util" }

-- Like awful.menu.clients, but only show clients of currently selected
-- tags.
function util.menu_clients_current_tags(menu, args)
    -- List of currently selected tags.
    local cls_tags = awful.screen.focused().selected_tags

    -- Final list of menu items.
    local cls_t = {}

    if cls_tags == nil then return nil end

    -- For each selected tag get all clients of that tag and add them to
    -- the menu. A click on a menu item will raise that client.
    for i = 1,#cls_tags
    do
        local t = cls_tags[i]
        local cls = t:clients()

        for k, c in pairs(cls)
        do
            cls_t[#cls_t + 1] = { awful.util.escape(c.name) or "",
                                  function ()
                                      c.minimized = false
                                      client.focus = c
                                      c:raise()
                                  end,
                                  c.icon }
        end
    end

    -- No clients? Then quit.
    if #cls_t <= 0 then return nil end

    -- menu may contain some predefined values, otherwise start with a
    -- fresh menu.
    if not menu then menu = {} end

    -- Set the list of items and show the menu.
    menu.items = cls_t
    local m = awful.menu.new(menu)
    m:show(args)
    return m
end

-- Magnify a client: Set it to "float" and resize it.
local magnified_client = nil
function util.magnify_client(c)
    if c and not awful.client.floating.get(c) then
        util.mc(c)
        magnified_client = c
    else
        awful.client.floating.set(c, false)
        magnified_client = nil
    end
end

-- https://github.com/copycat-killer/lain/issues/195
function util.mc(c)
    c = c or magnified_client
    if not c then return end

    c.floating   = true
    local s      = awful.screen.selected()
    local mg     = s.geometry
    local tag    = s.selected_tag
    local mwfact = beautiful.master_width_factor or 0.5
    local g      = {}
    g.width      = math.sqrt(mwfact) * mg.width
    g.height     = math.sqrt(mwfact) * mg.height
    g.x          = mg.x + (mg.width - g.width) / 2
    g.y          = mg.y + (mg.height - g.height) / 2

    if c then c:geometry(g) end -- if c is still a valid object
end

-- Read the nice value of pid from /proc.
local function get_nice_value(pid)
    local n = first_line('/proc/' .. pid .. '/stat')
    if not n then return 0 end

    -- Remove pid and tcomm. This is necessary because tcomm may contain
    -- nasty stuff such as whitespace or additional parentheses...
    n = string.gsub(n, '.*%) ', '')

    -- Field number 17 now is the nice value.
    fields = split(n, ' ')
    return tonumber(fields[17])
end

-- To be used as a signal handler for "focus"
-- This requires beautiful.border_focus{,_highprio,_lowprio}.
function util.niceborder_focus(c)
    local n = get_nice_value(c.pid)
    if n == 0
    then
        c.border_color = beautiful.border_focus
    elseif n < 0
    then
        c.border_color = beautiful.border_focus_highprio
    else
        c.border_color = beautiful.border_focus_lowprio
    end
end

-- To be used as a signal handler for "unfocus"
-- This requires beautiful.border_normal{,_highprio,_lowprio}.
function util.niceborder_unfocus(c)
    local n = get_nice_value(c.pid)
    if n == 0
    then
        c.border_color = beautiful.border_normal
    elseif n < 0
    then
        c.border_color = beautiful.border_normal_highprio
    else
        c.border_color = beautiful.border_normal_lowprio
    end
end

-- Non-empty tag browsing
-- direction in {-1, 1} <-> {previous, next} non-empty tag
function util.tag_view_nonempty(direction, sc)
   local s = sc or awful.screen.focused()
   local scr = screen[s]

   for i = 1, #s.tags do
       awful.tag.viewidx(direction, s)
       if #s.clients > 0 then
           return
       end
   end
end

-- {{{ Dynamic tagging
--
-- Add a new tag
function util.add_tag()
    awful.prompt.run {
        prompt       = "New tag name: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = function(name)
            if not name or #name == 0 then return end
            awful.tag.add(name, { screen = awful.screen.focused() }):view_only()
        end
    }
end

-- Rename current tag
function util.rename_tag()
    awful.prompt.run {
        prompt       = "Rename tag: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = function(new_name)
            if not new_name or #new_name == 0 then return end
            local t = awful.screen.focused().selected_tag
            if t then
                t.name = new_name
            end
        end
    }
end

-- Move current tag
-- pos in {-1, 1} <-> {previous, next} tag position
function util.move_tag(pos)
    local tag = awful.screen.focused().selected_tag
    local idx = awful.tag.getidx(tag)
    if tonumber(pos) <= -1 then
        awful.tag.move(idx - 1, tag)
    else
        awful.tag.move(idx + 1, tag)
    end
end

-- Delete current tag
-- Any rule set on the tag shall be broken
function util.delete_tag()
    local t = awful.screen.focused().selected_tag
    if not t then return end
    t:delete()
end
-- }}}

-- On the fly useless gaps change
function util.useless_gaps_resize(thatmuch)
    beautiful.useless_gap = tonumber(beautiful.useless_gap) + thatmuch
    awful.layout.arrange(mouse.screen)
end

-- Check if an element exist on a table
function util.element_in_table(element, tbl)
    for _, i in pairs(tbl) do
        if i == element then
            return true
        end
    end
    return false
end

return setmetatable(util, { __index = wrequire })
