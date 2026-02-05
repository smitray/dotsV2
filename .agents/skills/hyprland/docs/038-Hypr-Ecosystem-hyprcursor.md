---
title: hyprcursor
url: https://wiki.hypr.land/Hypr-Ecosystem/hyprcursor/
source: sitemap
fetched_at: 2026-02-01T09:23:25.678776719-03:00
rendered_js: false
word_count: 238
summary: This document explains the hyprcursor cursor theme format, how to install and configure it for Hyprland, and provides guidance for porting existing cursor themes while addressing compatibility issues with different application types.
tags:
    - cursor-theme
    - hyprland
    - xcursor
    - configuration
    - faq
    - themes
category: guide
---

[hyprcursor](https://github.com/hyprwm/hyprcursor) is a new cursor theme format that has many advantages over the widely used xcursor.

## Hyprcursor Themes[](#hyprcursor-themes)

You will need to obtain those yourself. If you are on the Discord server, see `#hyprcursor-themes`.

Put your theme(s) in `~/.local/share/icons` or `~/.icons`

Warning

It’s not recommended to put cursor themes in system-wide `/usr/share/icons` due to potential permission issues.

You can set your theme with envvars, or with `hyprctl setcursor`.

Env:

- `HYPRCURSOR_THEME` controls the theme.
- `HYPRCURSOR_SIZE` controls the cursor size.

example snippet of `hyprland.conf`:

## Creating / Porting Themes[](#creating--porting-themes)

Go to the [hyprcursor repo](https://github.com/hyprwm/hyprcursor)

See the `docs/` and `hyprcursor-util/` directories for instructions.

## Important Notes[](#important-notes)

Although many apps support server-side cursors (e.g. Qt, Chromium, Electron, Hypr Ecosystem) some apps still don’t (e.g. GTK).

Apps that do not support server-side cursors and hyprcursor will still fall back to XCursor.

For those apps, you need to export `XCURSOR_THEME` and `XCURSOR_SIZE` to a valid XCursor theme, and run

for gtk.

If `gsettings` schemas are not available to you (e.g. on NixOS you will get `No schemas installed`), you can run instead:

If the app is a flatpak, run:

and put your themes in both `/usr/share/themes` and `~/.themes`, also put your icons and XCursors in both `/usr/share/icons` and `~/.icons`.

## I Don’t Want to Use hyprcursor[](#i-dont-want-to-use-hyprcursor)

If you don’t have any hyprcursor themes installed, Hyprland will fall back to XCursor, and use whatever you define with `XCURSOR_THEME` and `XCURSOR_SIZE`.

## My Cursor Is a hyprland Icon?[](#my-cursor-is-a-hyprland-icon)

See [FAQ](https://wiki.hypr.land/FAQ)