
--[[

     Licensed under GNU General Public License v2
      * (c) 2015, worron
      * (c) 2013, Alexander Yakushev

--]]

-- Asynchronous io.popen for Awesome WM.
-- How to use:
-- asyncshell.request('wscript -Kiev', function(output) wwidget.text = output end)

-- Grab environment
local awful = require('awful')

-- Initialize tables for module
local asyncshell = { request_table = {}, id_counter = 0 }

-- Request counter
local function next_id()
    asyncshell.id_counter = (asyncshell.id_counter + 1) % 10000
    return asyncshell.id_counter
end

-- Remove given request
function asyncshell.clear(id)
    if asyncshell.request_table[id] then
        if asyncshell.request_table[id].timer then
            asyncshell.request_table[id].timer:stop()
            asyncshell.request_table[id].timer = nil
        end
        asyncshell.request_table[id] = nil
    end
end

-- Sends an asynchronous request for an output of the shell command
-- @param command Command to be executed and taken output from
-- @param callback Function to be called when the command finishes
-- @param timeout Maximum amount of time to wait for the result (optional)
function asyncshell.request(command, callback, timeout)
    local id = next_id()
    asyncshell.request_table[id] = { callback = callback }

    local formatted_command = string.gsub(command, '"','\"')
                              .. " | sed -e 's/\"/\\\\\"/g' -e ':a;N;$!ba;s/\\n/\\\\n/g'"

    local req = string.format(
        "echo \"asyncshell.deliver(%s, \\\"$(%s)\\\")\" | awesome-client &",
        id, formatted_command
    )

    awful.util.spawn_with_shell(req)

    if timeout then
        asyncshell.request_table[id].timer = timer({ timeout = timeout })
        asyncshell.request_table[id].timer:connect_signal("timeout", function() asyncshell.clear(id) end)
        asyncshell.request_table[id].timer:start()
    end
end

-- Calls the remembered callback function on the output of the shell command
-- @param id Request ID
-- @param output Shell command output to be delievered
function asyncshell.deliver(id, output)
    if asyncshell.request_table[id] then
        asyncshell.request_table[id].callback(output)
        asyncshell.clear(id)
    end
end

return asyncshell
