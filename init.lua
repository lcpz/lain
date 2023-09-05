--[[

     Lain
     Layouts, widgets and utilities for Awesome WM

     Licensed under GNU General Public License v2
      * (c) 2013, Luca CPZ

--]]

local requirePrefix= tostring(...):match(".*lain") or ""
if requirePrefix then
    requirePrefix=requirePrefix.."."
end

return {
    layout = require(requirePrefix .. "layout"),
    util   = require(requirePrefix .. "util"),
    widget = require(requirePrefix .. "widget")
}
