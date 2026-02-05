---
title: Using hyprctl
url: https://wiki.hypr.land/Configuring/Using-hyprctl/
source: sitemap
fetched_at: 2026-02-01T09:23:16.18043493-03:00
rendered_js: false
word_count: 671
summary: Provides documentation for hyprctl, a command-line utility for controlling Hyprland compositor features including dispatchers, configuration keywords, and system interactions.
tags:
    - hyprland
    - compositor
    - cli-tool
    - ipc
    - configuration
    - automation
category: reference
---

`hyprctl` is a utility for controlling some parts of the compositor from a CLI or a script. It should automatically be installed along with Hyprland.

Warning

*hyprctl* calls will be dispatched by the compositor *synchronously*, meaning any spam of the utility will cause slowdowns. It’s recommended to use `--batch` for many control calls, and limiting the amount of info calls.

For live event handling, see the [socket2](https://wiki.hypr.land/IPC/).

## Commands[](#commands)

### dispatch[](#dispatch)

Issue a `dispatch` to call a keybind dispatcher with an argument.

An argument has to be present, for dispatchers without parameters it can be anything.

To pass an argument starting with `-` or `--`, such as command line options to `exec` programs, pass `--` as an option. This will disable any subsequent parsing of options by *hyprctl*.

Examples:

Returns: `ok` on success, an error message on fail.

See [Dispatchers](https://wiki.hypr.land/Configuring/Dispatchers) for a list of dispatchers.

### keyword[](#keyword)

issue a `keyword` to call a config keyword dynamically.

Examples:

Returns: `ok` on success, an error message on fail.

### reload[](#reload)

Issue a `reload` to force reload the config.

### kill[](#kill)

Issue a `kill` to get into a kill mode, where you can kill an app by clicking on it. You can exit it with ESCAPE.

Kind of like xkill.

### setcursor[](#setcursor)

Sets the cursor theme and reloads the cursor manager. Will set the theme for everything except GTK, because GTK.

Please note that since 0.37.0, this only accepts hyprcursor themes. For legacy xcursor themes, use the `XCURSOR_THEME` and `XCURSOR_SIZE` env vars.

params: theme and size

e.g.:

### output[](#output)

Allows you to add and remove fake outputs to your preferred backend.

Usage:

or

Where `[backend]` is the name of the backend and `(name)` is an optional name for the output. If `(name)` is not specified, the default naming scheme will be used (`HEADLESS-2`, `WL-1`, etc.)

Note

`create` and `remove` can also be `add` or `destroy`, respectively.

Available backends:

- `wayland`: Creates an output as a Wayland window. This will only work if you’re already running Hyprland with the Wayland backend.
- `headless`: Creates a headless monitor output. If you’re running a VNC/RDP/ Sunshine server, you should use this.
- `auto`: Picks a backend for you. For example, if you’re running Hyprland from the TTY, `headless` will be chosen.

For example, to create a headless output named “test”:

And to remove it:

### switchxkblayout[](#switchxkblayout)

Sets the xkb layout index for a keyboard.

For example, if you set:

You can use this command to switch between them.

where `CMD` is either `next` for next, `prev` for previous, or `ID` for a specific one (in the above case, `us`: 0, `pl`: 1, `de`: 2). You can find the `DEVICE` using `hyprctl devices` command.

`DEVICE` can also be `current` or `all`, self-explanatory. Current is the `main` keyboard from `devices`.

Example command for a typical keyboard:

Note

If you want a single variant i.e. pl/dvorak on one layout but us/qwerty on the other, xkb parameters can still be blank, however the amount of comma-separated parameters have to match. Alternatively, a single parameter can be specified for it to apply to all three.

### seterror[](#seterror)

Sets the hyprctl error string. Will reset when Hyprland’s config is reloaded.

To disable:

### getprop[](#getprop)

Gets a property value of a window.

Where `window` is as described [here](https://wiki.hypr.land/Configuring/Dispatchers#parameter-explanation), and `property` is any which can be set with [setprop](https://wiki.hypr.land/Configuring/Dispatchers/#setprop).

#### Notes[](#notes)

- If `animationstyle` is unset, `(unset)` is returned.
- `min_size` defaults to `20 20`.
- `max_size` defaults to `inf inf` or `[null,null]` in JSON.

### notify[](#notify)

Sends a notification using the built-in Hyprland notification system.

For example:

Icon of `-1` means “No icon”

Color of `0` means “Default color for icon”

Icon list:

Optionally, you can specify a font size of the notification like so:

The default font-size is 13.

### dismissnotify[](#dismissnotify)

Dismisses all or up to AMOUNT notifications.

## Info[](#info)

For the getoption command, the option name should be written as `section:option`, e.g.:

See [Variables](https://wiki.hypr.land/Configuring/Variables) for sections and options you can use.

## Batch[](#batch)

You can also use `--batch` to specify a batch of commands to execute.

e.g.

`;` separates the commands

## Flags[](#flags)

You can specify flags for the request like this:

flag list: