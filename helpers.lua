--[[

     Licensed under GNU General Public License v2
      * (c) 2013, Luca CPZ

--]]

local spawn      = require("awful.spawn")
local timer      = require("gears.timer")
local debug      = require("debug")
local io         = { lines = io.lines,
                     open  = io.open }
local pairs      = pairs
local rawget     = rawget
local table      = { sort  = table.sort }

local Gio = require("lgi").Gio

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

-- check if the file exists and is readable
function helpers.file_exists(path)
    local file = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
end

-- get a table with all lines from a file
function helpers.lines_from(path)
    local lines = {}
    for line in io.lines(path) do
        lines[#lines + 1] = line
    end
    return lines
end

-- get a table with all lines from a file matching regexp
function helpers.lines_match(regexp, path)
    local lines = {}
    for line in io.lines(path) do
        if string.match(line, regexp) then
            lines[#lines + 1] = line
        end
    end
    return lines
end

-- get first line of a file
function helpers.first_line(path)
    local file, first = io.open(path, "rb"), nil
    if file then
        first = file:read("*l")
        file:close()
    end
    return first
end

-- get first non empty line from a file
function helpers.first_nonempty_line(path)
    for line in io.lines(path) do
        if #line then return line end
    end
    return nil
end

-- }}}

-- {{{ Timer maker

helpers.timer_table = {}

function helpers.newtimer(name, timeout, fun, nostart, stoppable)
    if not name or #name == 0 then return end
    name = (stoppable and name) or timeout
    if not helpers.timer_table[name] then
        helpers.timer_table[name] = timer({ timeout = timeout })
        helpers.timer_table[name]:start()
    end
    helpers.timer_table[name]:connect_signal("timeout", fun)
    if not nostart then
        helpers.timer_table[name]:emit_signal("timeout")
    end
    return stoppable and helpers.timer_table[name]
end

-- }}}

-- {{{ Pipe operations

-- run a command and execute a function on its output (asynchronous pipe)
-- @param cmd the input command
-- @param callback function to execute on cmd output
-- @return cmd PID
function helpers.async(cmd, callback)
    return spawn.easy_async(cmd,
    function (stdout, stderr, reason, exit_code)
        callback(stdout, exit_code)
    end)
end

-- like above, but call spawn.easy_async with a shell
function helpers.async_with_shell(cmd, callback)
    return spawn.easy_async_with_shell(cmd,
    function (stdout, stderr, reason, exit_code)
        callback(stdout, exit_code)
    end)
end

-- run a command and execute a function on its output line by line
function helpers.line_callback(cmd, callback)
    return spawn.with_line_callback(cmd, {
        stdout = function (line)
            callback(line)
        end,
    })
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


-- {{{ Network functions

-- Create a recieving buffer
-- NOTE: Not sure whether to export this with helpers or not
-- Probably just gonna leave it local for now
function generate_buffer(buffer_length)
    -- First, create an output buffer to recieve from
    local recv_buffer = " "
    -- We'll need to allocate `buffer_length` bytes to it
    for i=1,buffer_length do
        recv_buffer = recv_buffer .. " "
    end

    return recv_buffer
end

-- Wrapper function to send to any sort of address
function helpers.send_to_address(host, port, data, buffer_length, callback)
    -- Have a default buffer length of 1000
    if not buffer_length then
      buffer_length = 1000
    end

    -- Generate a buffer to store our result in
    local recv_buffer = generate_buffer(buffer_length)

    -- Check if we should be sending to a socket or an IP
    local is_socket = (string.sub(host, 1, 1) == "/")

    -- Create a client to listen and send with
    local client = Gio.SocketClient()

    local addr

    if is_socket then
        addr = Gio.UnixSocketAddress.new(host)
    else
        local inet_addr = gio.InetAddress.new_from_string(host)
        addr = Gio.InetSocketAddress.new(inet_addr, port)
    end

    local conn = client:connect(addr)

    local input_stream = conn:get_output_stream()
    local output_stream = conn:get_input_stream()

    input_stream:write(data)
    output_stream:read(recv_buffer)
    output_stream:read(recv_buffer)

    callback(recv_buffer)
end
-- }}} 

-- {{{ Misc

-- check if an element exist on a table
function helpers.element_in_table(element, tbl)
    for _, i in pairs(tbl) do
        if i == element then
            return true
        end
    end
    return false
end

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

-- create the partition of singletons of a given set
-- example: the trivial partition set of {a, b, c}, is {{a}, {b}, {c}}
function helpers.trivial_partition_set(set)
    local ss = {}
    for _,e in pairs(set) do
        ss[#ss+1] = {e}
    end
    return ss
end

-- creates the powerset of a given set
function helpers.powerset(s)
    if not s then return {} end
    local t = {{}}
    for i = 1, #s do
        for j = 1, #t do
            t[#t+1] = {s[i],unpack(t[j])}
        end
    end
    return t
end

-- }}}

return helpers
