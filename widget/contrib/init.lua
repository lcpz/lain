--[[

     Lain
     Layouts, widgets and utilities for Awesome WM

     Users contributed widgets section

     Licensed under GNU General Public License v2
      * (c) 2013, Luca CPZ

--]]

local requirePrefix = tostring(...):match(".*lain") or ""
if requirePrefix then
	requirePrefix = requirePrefix .. "."
end

local wrequire     = require(requirePrefix .. "helpers").wrequire
local setmetatable = setmetatable

local widget = { _NAME = requirePrefix .. "widget.contrib" }

return setmetatable(widget, { __index = wrequire })
