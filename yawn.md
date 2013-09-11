(YAhoo! Weather Notification)

Yawn provides brief and compact Yahoo! Weather notification.

Usage
-----

You can ``register`` Yawn to get a set of widgets, or ``attach`` it to
an existent widget.

### register

    yawn = lain.widgets.yawn(id, args)

- ``id``

    An integer that defines the WOEID code of your city.
    To obtain it you can google 'yahoo weather %CITYNAME%' and follow the first link.
    It will look like:

        http://weather.yahoo.com/united-states/california/san-diego-2487889/

    and the last number in that link will be the ID you need.

- ``args``

    A required table which can contain:

    Variables | Meaning | Type | Possible values | Default value
    --- | --- | --- | --- | ---
    `u` | Units | string | "c" (Celsius), "f" (Fahrenheit) | "c"
    `timeout` | Refresh timeout seconds | int | integers | 600
    `settings` | User settings | function | function | empty function

    `settings` can use strings `forecast`, `units`, and can modify `notification_preset` table, which
     will be the preset for the naughty notifications. Check [here](http://awesome.naquadah.org/doc/api/modules/naughty.html#notify) for the list of variables it can contain.

The function `register` creates an imagebox icon and a textbox widget. Add them to you wibox like this:

    right_layout:add(yawn.icon)
    right_layout:add(yawn.widget)

Hovering over ``yawn.icon`` will display the notification.

### attach

    lain.widgets.yawn.attach(widget, id, args)

Arguments:

- ``widget``
 
    The widget which you want to attach Yawn to.

- ``id``

    Same as in ``register``.

- ``args``
 
   Same as in ``register``.

Hovering over ``widget`` will display the notification.

Popup shortcut
--------------

You can also create a keybinding for the weather popup like this:

    awful.key( { "Mod1" }, "w", function () yawn.show(5) end )

where ``show`` argument is an integer defining timeout seconds.

Localization
------------

Default language is English, but Yawn can be localized.

Move to `localizations` subdirectory and fill `localization_template`.

Once you're done, rename it like your locale id. In my case:

    $ lua
    Lua 5.2.2  Copyright (C) 1994-2013 Lua.org, PUC-Rio
    > print(os.getenv("LANG"):match("(%S*$*)[.]"))
    it_IT
    >

hence I named my file "it_IT" (Italian localization).

**NOTE:** If you create a localization, feel free to send me! I will add it.