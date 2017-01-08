
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
                                                  
--]]

local debug  = require("debug")

local assert = assert
local capi   = { timer = require ("gears.timer") }
local io     = { open  = io.open,
                 lines = io.lines,
                 popen = io.popen }
local rawget = rawget
local table  = { sort   = table.sort }

local wibox  = require("wibox")

-- Lain helper functions for internal use
-- lain.helpers
local helpers = {}

helpers.lain_dir    = debug.getinfo(1, 'S').source:match[[^@(.*/).*$]]
helpers.icons_dir   = helpers.lain_dir .. 'icons/'
helpers.scripts_dir = helpers.lain_dir .. 'scripts/'

-- {{{ Modules loader

function helpers.wrequire(table, key)
    local module = rawget(table, key)
    return module or require(table._NAME .. '.' .. key)
end

-- }}}

-- {{{ File operations

-- see if the file exists and is readable
function helpers.file_exists(file)
  local f = io.open(file)
  if f then
      local s = f:read()
      f:close()
      f = s
  end
  return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
function helpers.lines_from(file)
  if not helpers.file_exists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end

-- match all lines from a file, returns an empty
-- list/table if the file or match does not exist
function helpers.lines_match(regexp, file)
	local lines = {}
	for index,line in pairs(helpers.lines_from(file)) do
		if string.match(line, regexp) then
			lines[index] = line
		end
	end
	return lines
end

-- get first line of a file, return nil if
-- the file does not exist
function helpers.first_line(file)
    return helpers.lines_from(file)[1]
end

-- get first non empty line from a file,
-- returns nil otherwise
function helpers.first_nonempty_line(file)
  for k,v in pairs(helpers.lines_from(file)) do
    if #v then return v end
  end
  return nil
end

-- }}}

-- {{{ Timer maker

helpers.timer_table = {}

function helpers.newtimer(_name, timeout, fun, nostart)
    local name = timeout
    if not helpers.timer_table[name] then
        helpers.timer_table[name] = capi.timer({ timeout = timeout })
        helpers.timer_table[name]:start()
    end
    helpers.timer_table[name]:connect_signal("timeout", fun)
    if not nostart then
        helpers.timer_table[name]:emit_signal("timeout")
    end
end

-- }}}

-- {{{ Pipe operations

-- read the full output of a command output
function helpers.read_pipe(cmd)
   local f = assert(io.popen(cmd))
   local output = f:read("*all")
   f:close()
   return output
end

-- return line iterator of a command output
function helpers.pipelines(...)
    local f = assert(io.popen(...))
    return function () -- iterator
        local data = f:read()
        if data == nil then f:close() end
        return data
    end
end

-- }}}

-- {{{ A map utility

helpers.map_table = {}

function helpers.set_map(element, value)
    helpers.map_table[element] = value
end

function helpers.get_map(element)
    return helpers.map_table[element]
end

-- }}}

-- {{{ Misc

-- iterate over table of records sorted by keys
function helpers.spairs(t)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    table.sort(keys)

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-- create a lain textbox widget
function helpers.make_widget_textbox()
    local w = wibox.widget.textbox('')
    local t = wibox.widget.base.make_widget(w)
    t.widget = w
    return t
end

-- }}}

return helpers
