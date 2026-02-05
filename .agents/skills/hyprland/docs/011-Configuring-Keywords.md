---
title: Keywords
url: https://wiki.hypr.land/Configuring/Keywords/
source: sitemap
fetched_at: 2026-02-01T09:22:25.919204986-03:00
rendered_js: false
word_count: 579
summary: This document provides configuration guidance for Hyprland, covering advanced keyword usage, script execution, file sourcing, input device configuration, and environment variable settings.
tags:
    - hyprland
    - configuration
    - keywords
    - script-execution
    - input-devices
    - environment-variables
    - file-sourcing
category: reference
---

Keywords are not variables, but “commands” for more advanced configuring. On this page, you will be presented with some that do not deserve their own page.

See the sidebar for more keywords to control binds, animations, monitors, et cetera.

Warning

Please remember, that for ALL arguments separated by a comma, if you want to leave one of them empty, you cannot reduce the number of commas, *unless told otherwise in a specific section*:

## Executing[](#executing)

You can execute a shell script on:

- startup of the compositor
- every time the config is reloaded.
- shutdown of the compositor

`exec-once = command` will execute only on launch ([support rules](https://wiki.hypr.land/Configuring/Dispatchers/#executing-with-rules))

`execr-once = command` will execute only on launch

`exec = command` will execute on each reload ([support rules](https://wiki.hypr.land/Configuring/Dispatchers/#executing-with-rules))

`execr = command` will execute on each reload

`exec-shutdown = command` will execute only on shutdown

## Sourcing (multi-file)[](#sourcing-multi-file)

Use the `source` keyword to source another file. Globbing is supported

For example, in your `hyprland.conf` you can:

And Hyprland will enter that file and parse it like a Hyprland config.

Please note it’s LINEAR. Meaning lines above the `source =` will be parsed first, then lines inside `~/.config/hypr/myColors.conf`, then lines below.

## Gestures[](#gestures)

Use [libinput-gestures](https://github.com/bulletmark/libinput-gestures) with `hyprctl` if you want to expand Hyprland’s gestures beyond what’s offered in [Variables](https://wiki.hypr.land/Configuring/Variables).

## Per-device input configs[](#per-device-input-configs)

Per-device config options will overwrite your options set in the `input` section. It’s worth noting that ONLY values explicitly changed will be overwritten.

In order to apply per-device config options, add a new category like this:

The `name` can be easily obtained by checking the output of `hyprctl devices`.

Inside of it, put your config options. All options from the `input` category (and all subcategories, e.g. `input:touchpad`) can be put inside, **EXCEPT**:

- `force_no_accel`
- `follow_mouse`
- `float_switch_override_focus`

Properties that change names:

You can also use the `output` setting for tablets to bind them to outputs. Remember to use the name of the `Tablet` and not `Tablet Pad` or `Tablet tool`.

Additional properties only present in per-device configs:

- `enabled` -&gt; (only for mice / touchpads / touchdevices / keyboards)
  
  - enables / disables the device (connects / disconnects from the on-screen cursor)
  - default: Enabled
- `keybinds` -&gt; (only for devices that send key events)
  
  - enables / disables keybinds for the device
  - default: Enabled

Example config section:

Example modifying per-device config values using `hyprctl`:

Note

Per-device layouts will by default not alter the keybind keymap, so for example with a global keymap of `us` and a per-device one of `fr`, the keybinds will still act as if you were on `us`.

You can change this behavior by setting `resolve_binds_by_sym = 1`. In that case you’ll need to type the symbol specified in the bind to activate it.

## Wallpapers[](#wallpapers)

The “Hyprland” background you see when you first start Hyprland is **NOT A WALLPAPER**, it’s the default image rendered at the bottom of the render stack.

To set a wallpaper, use a wallpaper utility like [hyprpaper](https://github.com/hyprwm/hyprpaper) or [swaybg](https://github.com/swaywm/swaybg).

More can be found in [Useful Utilities](https://wiki.hypr.land/Useful-Utilities).

## Setting the environment[](#setting-the-environment)

Note

A new environment cannot be passed to already running processes. If you change / add / remove an `env =`entry when Hyprland is running, only newly spawned apps will pick up the changes.

You can use the `env` keyword to set environment variables, e.g:

You can also add a `d` flag if you want the env var to be exported to D-Bus (systemd only):

Warning

Hyprland puts the raw string to the env var. You should *not* add quotes around the values.

e.g.:

and ***NOT***