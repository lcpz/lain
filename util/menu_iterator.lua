--[[

     Licensed under GNU General Public License v2
      * (c) 2017, Simon Désaulniers <sim.desaulniers@gmail.com>
      * (c) 2017, Uli Schlachter
      * (c) 2017, Jeferson Siqueira <jefersonlsiq@gmail.com>

--]]

-- Menu iterator using naughty.notify

local naughty = require("naughty")
local util = require("lain.util")

local state = { cid = nil }

local function naughty_destroy_callback(reason)
    if reason == naughty.notificationClosedReason.expired or
        reason == naughty.notificationClosedReason.dismissedByUser then
        local actions = state.index and state.menu[state.index - 1][2]
        if actions then
            for _,action in pairs(actions) do
                -- don't try to call nil callbacks
                if action then action() end
            end
            state.index = nil
        end
    end
end

-- Iterates over a list of pairs {label, {callbacks}}. After timeout, the last
-- visited choice associated callbacks are executed.
-- * menu:    a list of pairs {label, {callbacks}
-- * timeout: time to wait before confirming menu selection
-- * icon:    icon to display left to the choiced label
local function iterate(menu, timeout, icon)
    timeout = timeout or 4 -- default timeout for each menu entry
    icon    = icon or nil  -- icon to display on the menu

    -- Build the list of choices
    if not state.index then
        state.menu = menu
        state.index = 1
    end

    -- Select one and display the appropriate notification
    local label, action
    local next  = state.menu[state.index]
    state.index = state.index + 1

    if not next then
        label = "Cancel"
        state.index = nil
    else
        label, _ = unpack(next)
    end
    state.cid = naughty.notify({
        text = label,
        icon = icon,
        timeout = timeout,
        screen = mouse.screen,
        replaces_id = state.cid,
        destroy = naughty_destroy_callback
    }).id
end

-- Generates a menu compatible with the iterate function argument and suitable
-- for the following cases:
-- * all possible choices individually.
-- * all possible choices are all the possible subsets of the set of individual
--   choices (the powerset)
--
-- The following describes the function arguments:
-- * args: an array containing the following members:
--   * choices:       the list of choices from which to generate the menu
--   * name:          the displayed name of the menu (in the form "name: choices")
--   * selected_cb:   the callback to execute for each selected choice. Takes
--                    the choice as a string argument. The function
--                    menu_iterator.naughty_destroy_callback will handle nil
--                    callbacks. It is then fine to pass nil callbacks.
--   * rejected_cb:   the callback to execute for each rejected choice (in the
--                    set of possible choices, but not selected). Takes the
--                    choice as a string argument. The function
--                    menu_iterator.naughty_destroy_callback will handle nil
--                    callbacks. It is then fine to pass nil callbacks.
--   * extra_choices: an array of pairs { choice_text, cb } for extra choices to
--                    be added to the menu. The function
--                    menu_iterator.naughty_destroy_callback will handle nil
--                    callbacks. It is then fine to pass nil callbacks.
--   * combination:   the combination of choice to generate. Possible choices
--                    are "powerset" and "single" (the default).
local function menu(args)
    local choices     = assert(args.choices or args[1])
    local name        = assert(args.name or args[2])
    local selected_cb = args.selected_cb
    local rejected_cb = args.rejected_cb
    local extra_choices = args.extra_choices or {}

    local ch_combinations = args.combination == "powerset" and helpers.powerset(choices) or helpers.trivial_partition_set(choices)
    for _,c in pairs(extra_choices) do
        ch_combinations = awful.util.table.join(ch_combinations, {{c[1]}})
    end

    local m = {}
    for _,c in pairs(ch_combinations) do
        if #c > 0 then
            local cbs = {}
            -- selected choices
            for _,ch in pairs(c) do
                if awful.util.table.hasitem(choices, ch) then
                    cbs[#cbs + 1] = selected_cb and function() selected_cb(ch) end or nil
                end
            end

            -- rejected choices
            for _,ch in pairs(choices) do
                if not awful.util.table.hasitem(c, ch) and awful.util.table.hasitem(choices, ch) then
                    cbs[#cbs + 1] = rejected_cb and function() rejected_cb(ch) end or nil
                end
            end

            -- add user extra choices (like the choice "None" for e.g.)
            for _,x in pairs(extra_choices) do
                if x[1] == c[1] then
                    cbs[#cbs + 1] = x[2]
                end
            end

            m[#m + 1] = { name .. ": " .. table.concat(c, " + "), cbs }
        end
    end

    return m
end

return {
    iterate = iterate,
    menu    = menu
}
