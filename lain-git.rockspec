package = "lain"
version = "git"
source = {
   url = "https://github.com/copycat-killer/lain",
   tag = "git"
}
description = {
   summary = "Layout, widgets and utilities for Awesome WM",
   detailed = [[
        Successor of awesome-vain, this module provides new layouts, a set of widgets and utility functions, with the aim of improving Awesome usability and configurability.

        Optional dependency: curl (for IMAP and weather widgets).
    ]],
   homepage = "https://github.com/copycat-killer/lain",
   license = "GPL v2"
}
dependencies = {
   "lua >= 5.3",
   "awesome >= 4.0",
   "curl"
}
supported_platforms = { "linux" }
build = {
   type = "builtin",
   modules = { lain = "init.lua" }
}
