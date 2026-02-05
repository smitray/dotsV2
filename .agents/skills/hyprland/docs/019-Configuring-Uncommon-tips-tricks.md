---
title: Uncommon tips & tricks
url: https://wiki.hypr.land/Configuring/Uncommon-tips--tricks/
source: sitemap
fetched_at: 2026-02-01T09:23:20.888053401-03:00
rendered_js: false
word_count: 773
summary: This document provides guidance on configuring various keyboard and window management features in Hyprland, including switchable keyboard layouts, keybind customization, and system integration.
tags:
    - keyboard-layout
    - keybind
    - hyprland-config
    - xkb-settings
    - window-management
    - caps-lock
    - function-keys
    - scripting
category: guide
---

## Switchable keyboard layouts[](#switchable-keyboard-layouts)

The easiest way to accomplish this is to set this using XKB settings, for example:

Variants are set per layout.

Warning

The first layout defined in the input section will be the one used for binds by default.

For example: `us,ua` -&gt; config binds would be e.g. `SUPER, A`, while on `ua,us` -&gt; `SUPER, Cyrillic_ef`

You can change this behavior globally or per-device by setting `resolve_binds_by_sym = 1`. In that case, binds will activate when the symbol typed matches the symbol specified in the bind.

For example: if your layouts are `us,fr` and have a bind for `SUPER, A` you’d need to press the first letter on the second row while the `us` layout is active and the first letter on the first row while the `fr` layout is active.

You can also bind a key to execute `hyprctl switchxkblayout` for more keybind freedom. See [Using hyprctl](https://wiki.hypr.land/Configuring/Using-hyprctl).

To find the valid layouts and `kb_options`, you can check out the `/usr/share/X11/xkb/rules/base.lst`. For example:

To get the layout name of a language:

To get the list of keyboard shortcuts you can put in the `kb_options` to toggle keyboard layouts:

## Disabling keybinds with one master keybind[](#disabling-keybinds-with-one-master-keybind)

If you want to disable all keybinds with another keybind (make a keybind toggle of sorts) you can just use a submap with only a keybind to exit it.

## Remapping Caps Lock[](#remapping-caps-lock)

You can customize the behavior of the Caps Lock key using `kb_options`.

To view all available options related to Caps Lock, run:

For example, to remap Caps lock to Ctrl:

To swap Caps Lock and Escape:

You can also find additional `kb_options` unrelated to Caps Lock in `/usr/share/X11/xkb/rules/base.lst`.

## Set F13-F24 as usual function keys[](#set-f13-f24-as-usual-function-keys)

By default, F13-F24 are mapped by xkb as various “XF86” keysyms. These cause binding issues in many programs. One example is OBS Studio, which does not detect the XF86 keysyms as usable keybindings, making you unable to use them for binds. This option simply maps them back to the expected F13-F24 values, which are bindable as normal.

Warning

This option was only added recently to `xkeyboard-config`. Please ensure you are on version 2.43 or greater for this option to do anything.

## Minimize windows using special workspaces[](#minimize-windows-using-special-workspaces)

This approach uses special workspaces to mimic the “minimize window” function, by using a single keybind to toggle the minimized state. Note that one keybind can only handle one window.

## Show desktop[](#show-desktop)

This approach uses same principle as the [Minimize windows using special workspaces](#minimize-windows-using-special-workspaces) section. It moves all windows from current workspace to a special workspace named `desktop`. Showing desktop state is remembered per workspace.

Create a script:

then bind it:

## Minimize Steam instead of killing[](#minimize-steam-instead-of-killing)

Steam will exit entirely when its last window is closed using the `killactive` dispatcher. To minimize Steam to tray, use the following script to close applications:

## Shimeji[](#shimeji)

To use Shimeji programs like [this](https://codeberg.org/thatonecalculator/spamton-linux-shimeji), set the following rules:

Note

The app indicator probably won’t show, so you’ll have to `killall -9 java` to kill them.

![Demo GIF of Spamton Shimeji](https://github.com/hyprwm/hyprland-wiki/assets/36706276/261afd03-bf41-4513-b72b-3483d43d418c)

## Toggle animations/blur/etc hotkey[](#toggle-animationsbluretc-hotkey)

For increased performance in games, or for less distractions at a keypress

1. create file `~/.config/hypr/gamemode.sh && chmod +x ~/.config/hypr/gamemode.sh` and add:

Edit to your liking of course. If animations are enabled, it disables all the pretty stuff. Otherwise, the script reloads your config to grab your defaults.

2. Add this to your `hyprland.conf`:

The hotkey toggle will be WIN+F1, but you can change this to whatever you want.

## Zoom[](#zoom)

To zoom using Hyprland’s built-in zoom utility

Warning

If mouse wheel bindings work only for the first time, you should probably reduce reset time with `binds:scroll_event_delay`

## Alt tab behaviour[](#alt-tab-behaviour)

To mimic DE’s alt-tab behaviour. Here is an example that uses foot, fzf, [grim-hyprland](https://github.com/eriedaberrie/grim-hyprland) and chafa to the screenshot in the terminal.

![alttab](https://github.com/user-attachments/assets/2a260809-b1b0-4f72-8644-46cc9d8b8971)

Dependencies :

- foot
- fzf
- [grim-hyprland](https://github.com/eriedaberrie/grim-hyprland)
- chafa
- jq

<!--THE END-->

1. add this to your config

<!--THE END-->

2. create file `touch $XDG_CONFIG_HOME/hypr/scripts/alttab/alttab.sh && chmod +x $XDG_CONFIG_HOME/hypr/scripts/alttab/alttab.sh` and add:

I chose to exclude windows that are in special workspaces but it can be modified by removing `select(.workspace.id >= 0)`

3. create file `touch $XDG_CONFIG_HOME/hypr/scripts/alttab/preview.sh && chmod +x $XDG_CONFIG_HOME/hypr/scripts/alttab/preview.sh` and add:

<!--THE END-->

4. create file `touch $XDG_CONFIG_HOME/hypr/scripts/alttab/disable.sh && chmod +x $XDG_CONFIG_HOME/hypr/scripts/alttab/disable.sh` and add:

<!--THE END-->

5. create file `touch $XDG_CONFIG_HOME/hypr/scripts/alttab/enable.sh && chmod +x $XDG_CONFIG_HOME/hypr/scripts/alttab/enable.sh` and add:

## Config versioning[](#config-versioning)

Some updates add breaking changes, which can be anticipated by looking at the git development branch.

Since Hyprland 0.53, we export a variable for each major version, that looks like this:

You can make your configs conditional, e.g.:

The -git branch exports the variable for the next major release.

All future releases will export all *past* variables as well, e.g. 0.54 will also export 0.53.