rockspec_format = "3.0"
package = "lain"
version = "scm-1"
source = {
   url = "git+https://github.com/lcpz/lain.git"
}
description = {
   summary = "Layout, widgets and utilities for Awesome WM",
   detailed = "Alternative layouts, asynchronous widgets and utility functions for Awesome WM. Non-Lua dependency: curl (for IMAP, MPD and weather widgets).",
   homepage = "https://github.com/lcpz/lain",
   issues_url = "https://github.com/lcpz/lain/issues",
   maintainer = "Luca Cpz",
   license = "GPL2"
}
dependencies = {
   "lua >= 5.3",
   "dkjson >= 2.6-1"
}
supported_platforms = { "linux" }
build = {
   type = "builtin",
   modules = {
      ["lain"] = "init.lua",
      ["lain.helpers"] = "helpers.lua",
      ["lain.layout"] = "layout/init.lua",
      ["lain.layout.cascade"] = "layout/cascade.lua",
      ["lain.layout.centerwork"] = "layout/centerwork.lua",
      ["lain.layout.termfair"] = "layout/termfair.lua",
      ["lain.util"] = "util/init.lua",
      -- ["lain.util.dkjson"] = "util/dkjson.lua", -- RESOLVED BY DEPENDENCY TO dkjson
      ["lain.util.markup"] = "util/markup.lua",
      ["lain.util.menu_iterator"] = "util/menu_iterator.lua",
      ["lain.util.quake"] = "util/quake.lua",
      ["lain.util.separators"] = "util/separators.lua",
      ["lain.widget"] = "widget/init.lua",
      ["lain.widget.contrib"] = "widget/contrib/init.lua",
      ["lain.widget.contrib.moc"] = "widget/contrib/moc.lua",
      ["lain.widget.contrib.redshift"] = "widget/contrib/redshift.lua",
      ["lain.widget.contrib.task"] = "widget/contrib/task.lua",
      ["lain.widget.contrib.tp_smapi"] = "widget/contrib/tp_smapi.lua",
      ["lain.widget.alsa"] = "widget/alsa.lua",
      ["lain.widget.alsabar"] = "widget/alsabar.lua",
      ["lain.widget.bat"] = "widget/bat.lua",
      ["lain.widget.cal"] = "widget/cal.lua",
      ["lain.widget.cpu"] = "widget/cpu.lua",
      ["lain.widget.fs"] = "widget/fs.lua",
      ["lain.widget.imap"] = "widget/imap.lua",
      ["lain.widget.mem"] = "widget/mem.lua",
      ["lain.widget.mpd"] = "widget/mpd.lua",
      ["lain.widget.net"] = "widget/net.lua",
      ["lain.widget.pulse"] = "widget/pulse.lua",
      ["lain.widget.pulsebar"] = "widget/pulsebar.lua",
      ["lain.widget.sysload"] = "widget/sysload.lua",
      ["lain.widget.temp"] = "widget/temp.lua",
      ["lain.widget.weather"] = "widget/weather.lua"
   }
}
