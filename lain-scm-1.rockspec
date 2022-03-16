package = "lain"
version = "scm-1"
source = {
   url = "git+https://github.com/lcpz/lain.git",
   tag = "master"
}
description = {
   summary = "Layout, widgets and utilities for Awesome WM",
   detailed = [[
        Successor of awesome-vain, this module provides alternative layouts, asynchronous widgets and utility functions for Awesome WM.

        Dependencies: curl (for IMAP, MPD and weather widgets); Glib >= 2.54 (for filesystems widget).
    ]],
   homepage = "https://github.com/lcpz/lain",
   license = "GPL-2.0"
}
dependencies = {
   "lua >= 5.1",
   "dkjson >= 2.6-1"
}
supported_platforms = { "linux" }
build = {
   type = "builtin",
   modules = { lain = "init.lua" }
}

