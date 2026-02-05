---
title: hyprpaper
url: https://wiki.hypr.land/Hypr-Ecosystem/hyprpaper/
source: sitemap
fetched_at: 2026-02-01T09:22:06.23366203-03:00
rendered_js: false
word_count: 247
summary: This document provides comprehensive instructions for installing, configuring, and using hyprpaper, a wallpaper utility for Hyprland that supports IPC control and can be configured to run at startup.
tags:
    - hyprland
    - wallpaper
    - ipc
    - configuration
    - startup
    - tutorial
category: guide
---

[hyprpaper](https://github.com/hyprwm/hyprpaper) is a fast, IPC-controlled wallpaper utility for Hyprland.

## Installation[](#installation)

**Arch**

**openSUSE**

**Fedora**

## Configuration[](#configuration)

The config file is located at `~/.config/hypr/hyprpaper.conf`. It is not required.

### Setting wallpapers[](#setting-wallpapers)

Wallpapers are set as anonymous special categories. Monitor can be left empty for a fallback.

variabledescriptionvalue`monitor`Monitor to display this wallpaper on. If empty, will use this wallpaper as a fallbackmonitor ID`path`Path to an image file or a directory containing image files (non recursively)path`fit_mode`Determines how to display the image. Optional and defaults to `cover``contain`|`cover`|`tile`|`fill``timeout`Timeout between each wallpaper change (in seconds, if `path` is a directory). Optional and defaults to 30 secondsint

### Run at Startup[](#run-at-startup)

To run hyprpaper at startup edit `hyprland.conf` and add: `exec-once = hyprpaper`.  
If you start Hyprland with [uwsm](https://wiki.hypr.land/Useful-Utilities/Systemd-start), you can also use the `systemctl --user enable --now hyprpaper.service` command.

### Misc Options[](#misc-options)

These should be set outside of the `wallpaper{...}` sections.

variabledescriptiontypedefault`splash`enable rendering of the hyprland splash over the wallpaperbool`true``splash_offset`how far up should the splash be displayedfloat`20``splash_opacity`how opaque the splash isfloat`0.8``ipc`whether to enable IPCbool`true`

### Sourcing[](#sourcing)

Use the `source` keyword to source another file. Globbing, tilde expansion and relative paths are supported.

Please note it’s LINEAR. Meaning lines above the `source =` will be parsed first, then lines inside `~/.config/hypr/hyprpaper.d/*.conf` files, then lines below.

## IPC[](#ipc)

hyprpaper supports IPC via `hyprctl`. You can set wallpapers like so:

`fit_mode` is optional, and `mon` can be empty for a fallback, just like in the config file. The fallback wallpaper only applies to monitors that have never had a specific monitor target assigned.