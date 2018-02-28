package = "lain"
version = "git"
source = {
   url = "https://github.com/lcpz/lain",
   tag = "git"
}
description = {
   summary = "Layout, widgets and utilities for Awesome WM",
   detailed = [[
        Successor of awesome-vain, this module provides alternative layouts, asynchronous widgets and utility functions for Awesome WM.

        Dependencies: curl (for IMAP, MPD and weather widgets); Glib >= 2.5.4 (for filesystems widget).
    ]],
   homepage = "https://github.com/lcpz/lain",
   license = "GPL-2.0"
}
dependencies = {
   "lua >= 5.1",
   "awesome >= 4.0",
   "Glib >= 2.5.4",
   "curl"
}
supported_platforms = { "linux" }
build = {
   type = "builtin",
   modules = { lain = "init.lua" }
}
