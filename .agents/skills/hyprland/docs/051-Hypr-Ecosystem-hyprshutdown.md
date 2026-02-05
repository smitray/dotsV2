---
title: hyprshutdown
url: https://wiki.hypr.land/Hypr-Ecosystem/hyprshutdown/
source: sitemap
fetched_at: 2026-02-01T09:23:15.285560787-03:00
rendered_js: false
word_count: 60
summary: This document explains how to use hyprshutdown, a graceful shutdown utility for Hyprland that properly exits applications before shutting down the system.
tags:
    - hyprland
    - shutdown
    - graceful-exit
    - gui
    - system-management
category: guide
---

[hyprshutdown](https://github.com/hyprwm/hyprshutdown) is a graceful shutdown utility. It opens a GUI and gracefully asks apps to exit, then quits Hyprland. It’s the recommended way to exit hyprland, as otherwise (e.g. `dispatch exit`) apps will die instead of exiting.

## Tips and tricks[](#tips-and-tricks)

If you want to shut the system down, or reboot, instead of logging out, you can do things like this:

```
hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0'
hyprshutdown -t 'Restarting...' --post-cmd 'reboot'
```