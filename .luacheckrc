-- Only allow symbols available in all Lua versions
std = "min"

allow_defined = true
max_line_length = false
cache = true

-- Global objects defined by the C code
read_globals = {
    "awesome",
    "mousegrabber",
    "table.unpack",
    "unpack",
    "utf8"
}

globals = {
    "client",
    "mouse",
    "root",
    "screen"
}

-- https://luacheck.readthedocs.io/en/stable/warnings.html
ignore = {
    "131"
}
