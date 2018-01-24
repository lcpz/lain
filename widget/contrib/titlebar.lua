--[[

    Licensed under GNU General Public License v2
    * (c) 2018, Bill Ayala

--]]

local layout = require("wibox.layout.fixed")
local widget = require("wibox.widget")
local button = require("awful.button")
local join   = require("gears.table").join
local markup = require("lain.util").markup.fontfg
local escape = require("awful.util").escape

-- Global titlebar
-- lain.widget.contrib.titlebar

local function factory(args)
    local args     = args or {}
    local order    = args.order or {"close", "max", "ontop", "sticky", "floating", "separator", "title"}

    local titlebar
    if args.orientation == "vertical" then
        titlebar = layout.vertical()
    else
        titlebar = layout.horizontal()
    end

    local clickable
    if args.clickable == false then
        clickable = false
    else
        clickable = true
    end

    for _, part in ipairs(order) do -- Only show elements included in order
        if part == "close" then
            local close_button = widget.imagebox()
            local close_icon   = args.close_icon

            titlebar:add(close_button)

            if clickable then
                close_button:buttons(join(button({}, 1, function() if client.focus then client.focus:kill() end end)))
            end

            client.connect_signal("focus", function() close_button:set_image(close_icon) end)
            client.connect_signal("unfocus", function() close_button:set_image() end)

        elseif part == "ontop" then
            local ontop_button   = widget.imagebox()
            local ontop_icon     = args.ontop_icon
            local ontop_off_icon = args.ontop_off_icon

            function update_ontop(c)
                if c == client.focus then
                    if c.ontop then
                        ontop_button:set_image(ontop_icon)
                    else
                        ontop_button:set_image(ontop_off_icon)
                    end
                end
            end

            titlebar:add(ontop_button)

            if clickable then
                ontop_button:buttons(join(button({}, 1, function()
                    if client.focus then
                        client.focus.ontop = not client.focus.ontop
                        update_ontop(client.focus)
                    end
                end)))
            end

            client.connect_signal("focus", update_ontop)
            client.connect_signal("property::ontop", update_ontop)
            client.connect_signal("unfocus", function() ontop_button:set_image() end)

        elseif part == "sticky" then
            local sticky_button   = widget.imagebox()
            local sticky_icon     = args.sticky_icon
            local sticky_off_icon = args.sticky_off_icon

            function update_sticky(c)
                if c == client.focus then
                    if c.sticky then
                        sticky_button:set_image(sticky_icon)
                    else
                        sticky_button:set_image(sticky_off_icon)
                    end
                end
            end

            titlebar:add(sticky_button)

            if clickable then
                sticky_button:buttons(join(button({}, 1, function()
                    if client.focus then
                        client.focus.sticky = not client.focus.sticky
                        update_sticky(client.focus)
                    end
                end)))
            end

            client.connect_signal("focus", update_sticky)
            client.connect_signal("property::sticky", update_sticky)
            client.connect_signal("unfocus", function() sticky_button:set_image() end)

        elseif part == "floating" then
            local floating_button   = widget.imagebox()
            local floating_icon     = args.floating_icon
            local floating_off_icon = args.floating_off_icon

            function update_floating(c)
                if c == client.focus then
                    if c.floating then
                        floating_button:set_image(floating_icon)
                    else
                        floating_button:set_image(floating_off_icon)
                    end
                end
            end

            titlebar:add(floating_button)

            if clickable then
                floating_button:buttons(join(button({}, 1, function()
                    if client.focus then
                        client.focus.floating = not client.focus.floating
                        update_floating(client.focus)
                    end
                end)))
            end

            client.connect_signal("focus", update_floating)
            client.connect_signal("property::floating", update_floating)
            client.connect_signal("unfocus", function() floating_button:set_image() end)

        elseif part == "max" then
            local max_button       = widget.imagebox()
            local max_icon         = args.max_icon
            local max_partial_icon = args.max_partial_icon
            local max_off_icon     = args.max_off_icon

            function update_max(c)
                if c == client.focus then
                    if c.maximized or (c.maximized_vertical and c.maximized_horizontal) then
                        max_button:set_image(max_icon)
                    elseif c.maximized_vertical or c.maximized_horizontal then
                        max_button:set_image(max_partial_icon)
                    else
                        max_button:set_image(max_off_icon)
                    end
                end
            end

            titlebar:add(max_button)

            if clickable then
                local max_vert_button  = args.max_vert_button or 2
                local max_horiz_button = args.max_horiz_button or 3

                max_button:buttons(join(
                    button({}, 1, function()
                        if client.focus then
                            client.focus.maximized = not client.focus.maximized
                            update_max(client.focus)
                        end
                    end),

                    button({}, max_vert_button, function()
                        if client.focus then
                            client.focus.maximized_vertical = not client.focus.maximized_vertical
                            update_max(client.focus)
                        end
                    end),

                    button({}, max_horiz_button, function()
                        if client.focus then
                            client.focus.maximized_horizontal = not client.focus.maximized_horizontal
                            update_max(client.focus)
                        end
                    end)))
            end

            client.connect_signal("focus", update_max)
            client.connect_signal("property::maximized", update_max)
            client.connect_signal("property::maximized_vertical", update_max)
            client.connect_signal("property::maximized_horizontal", update_max)
            client.connect_signal("unfocus", function() max_button:set_image() end)

        elseif part == "title" then
            local title       = widget.textbox()
            local font        = args.title_font or nil
            local color       = args.title_color or "#FFFFFF"
            local placeholder = escape(args.title_placeholder) or ""

            function update_title(c)
                if c == client.focus then
                    if c.name then
                        title.markup = markup(font, color, escape(c.name))
                    elseif c.class then
                        title.markup = markup(font, color, escape(c.class))
                    end
                end
            end

            titlebar:add(title)
            title.markup = markup(font, color, placeholder)

            client.connect_signal("focus", update_title)
            client.connect_signal("property::name", update_title)
            client.connect_signal("unfocus", function() title.markup = markup(font, color, placeholder) end)

        elseif part == "separator" then
            local separator = widget.textbox()
            local text      = args.separator or " "

            titlebar:add(separator)

            client.connect_signal("focus", function() separator.markup = text end)
            client.connect_signal("unfocus", function() separator.markup = "" end)
        end
    end

    return titlebar
end

return factory
