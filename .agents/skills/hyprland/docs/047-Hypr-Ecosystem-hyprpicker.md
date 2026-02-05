---
title: hyprpicker
url: https://wiki.hypr.land/Hypr-Ecosystem/hyprpicker/
source: sitemap
fetched_at: 2026-02-01T09:22:15.364389074-03:00
rendered_js: false
word_count: 99
summary: This document provides documentation for hyprpicker, a color picker utility for Hyprland that allows users to select colors from their screen with various optional flags for customization.
tags:
    - color-picker
    - hyprland
    - screen-color
    - utility
    - cli-tool
category: reference
---

[hyprpicker](https://github.com/hyprwm/hyprpicker) is a neat utility for picking a color from your screen on Hyprland.

## Configuration[](#configuration)

Doesn’t require configuration, only launch flags:

FlagDescriptionArgs`-a` | `--autocopy`Automatically copies the output to the clipboard (requires wl-clipboard)none`-f` | `--format=`Specifies the output format`cmyk` | `hex` | `rgb` | `hsl` | `hsv``-n` | `--no-fancy`Disables the “fancy” (aka. colored) outputtingnone`-h` | `--help`Shows the help messagenone`-r` | `--render-inactive`Render (freeze) inactive displaysnone`-z` | `--no-zoom`Disable the zoom lensnone`-q` | `--quiet`Disable most logs (leaves errors)none`-v` | `--verbose`Enable more logsnone`-t` | `--no-fractional`Disable fractional scaling supportnone`-d` | `--disable-hex-preview`Disable live preview of Hex codenone`-l` | `--lowercase-hex`Outputs the hexcode in lowercasenone`-V` | `--version`Print version infonone