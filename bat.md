[<- widgets](https://github.com/copycat-killer/lain/wiki/Widgets)

Shows in a textbox the remaining time and percentage capacity of your laptop battery, as well as
the current wattage.

Displays a notification when battery is low or critical.

	mybattery = lain.widgets.bat()

### input table

Variable | Meaning | Type | Default
--- | --- | --- | ---
`timeout` | Refresh timeout seconds | int | 30
`battery` | Identifier of the battery | string | "BAT0"
`notify` | Enable notifications | string | "on"
`settings` | User settings | function | empty function

`settings` can use the `bat_now` table, which contains the following strings:

- `status` ("Not present", "Charging", "Discharging");
- `perc`;
- `time`;
- `watt`.

To disable warning notifications, set `notify` to `"off"`.

### output

A textbox.