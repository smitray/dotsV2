---
title: Binds
url: https://wiki.hypr.land/Configuring/Binds/
source: sitemap
fetched_at: 2026-02-01T09:22:35.301693602-03:00
rendered_js: false
word_count: 1300
summary: This document provides comprehensive guidance on configuring keybinds in Hyprland, covering basic syntax, advanced features like mouse binds and submaps, and global keybinding strategies.
tags:
    - keybinding
    - hyprland
    - configuration
    - dispatchers
    - mouse-binds
    - submaps
    - global-shortcuts
    - xkbcommon
category: guide
---

## Basic[](#basic)

for example,

will bind opening Firefox to SUPER + SHIFT + Q

Note

For binding keys without a modkey, leave it empty:

*For a complete mod list, see [Variables](https://wiki.hypr.land/Configuring/Variables/#variable-types).*

*The dispatcher list can be found in [Dispatchers](https://wiki.hypr.land/Configuring/Dispatchers/#list-of-dispatchers).*

### Comma Syntax[](#comma-syntax)

Binds use commas as **argument separators**. The `bind` keyword expects exactly 4 arguments, so you need exactly 3 commas:

Note

Trailing commas in example configs (e.g., `bind = SUPER, Tab, cyclenext,`) indicate an empty `params` argument. Only include a trailing comma when the last argument is intentionally empty.

Warning

An accidental trailing comma becomes part of the argument (e.g., `firefox,` instead of `firefox`). If a keybind isn’t working, check for trailing commas!

## Uncommon syms / binding with a keycode[](#uncommon-syms--binding-with-a-keycode)

See the [xkbcommon-keysyms.h header](https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h) for all the keysyms. The name you should use is the segment after `XKB_KEY_`.

If you want to bind by a keycode, you can put it in the KEY position with a `code:` prefix, e.g.:

This will bind SUPER + t since t is keycode 28.

Note

If you are unsure of what your key’s name or keycode is, you can use [`wev`](https://github.com/jwrdegoede/wev) to find out.

## Misc[](#misc)

### Workspace bindings on non-QWERTY layouts[](#workspace-bindings-on-non-qwerty-layouts)

Keys used for keybinds need to be accessible without any modifiers in your layout.  
For instance, the [French AZERTY](https://en.wikipedia.org/wiki/AZERTY) layout uses SHIFT + *`unmodified key`* to write `0-9` numbers. As such, the workspace keybinds for this layout need to use the names of the *`unmodified keys`* , and will not work when using the `0-9` numbers.

Note

To get the correct name for an `unmodified_key`, refer to [the section on uncommon syms](#uncommon-syms--binding-with-a-keycode)

For help configuring the French AZERTY layout, see this [article](https://rherault.dev/articles/hyprland-fr-layout).

### Unbind[](#unbind)

You can also unbind a key with the `unbind` keyword, e.g.:

This may be useful for dynamic keybindings with `hyprctl`, e.g.:

Note

In `unbind`, key is case-sensitive It must exactly match the case of the `bind` you are unbinding.

## Bind flags[](#bind-flags)

`bind` supports flags in this format:

e.g.:

Available flags:

FlagNameDescription`l`lockedWill also work when an input inhibitor (e.g. a lockscreen) is active.`r`releaseWill trigger on release of a key.`c`clickWill trigger on release of a key or button as long as the mouse cursor stays inside `binds:drag_threshold`.`g`dragWill trigger on release of a key or button as long as the mouse cursor moves outside `binds:drag_threshold`.`o`long pressWill trigger on long press of a key.`e`repeatWill repeat when held.`n`non-consumingKey/mouse events will be passed to the active window in addition to triggering the dispatcher.`m`mouseSee the dedicated [Mouse Binds](#mouse-binds) section.`t`transparentCannot be shadowed by other binds.`i`ignore modsWill ignore modifiers.`s`separateWill arbitrarily combine keys between each mod/key, see [Keysym combos](#keysym-combos).`d`has descriptionWill allow you to write a description for your bind.`p`bypassBypasses the app’s requests to inhibit keybinds.`u`submap universalWill be active no matter the submap.

Example Usage:

### Mouse buttons[](#mouse-buttons)

You can also bind or unbind mouse buttons by prefacing the mouse keycode with `mouse:`, e.g.:

### Binding modkeys only[](#binding-modkeys-only)

To only bind modkeys, you need to use the TARGET modmask (with the activating mod) and the `r` flag, e.g.:

### Keysym combos[](#keysym-combos)

For an arbitrary combination of multiple keys, separate keysyms with `&` between each mod/key, and use the `s` flag, e.g.:

Note

Please note that this is only valid for keysyms and it makes all mods keysyms.  
If you don’t know what a keysym is use `wev` and press the key you want to use.

### Mouse wheel[](#mouse-wheel)

You can also bind mouse wheel events with `mouse_up` and `mouse_down` (or `mouse_left` and `mouse_right` if your mouse supports horizontal scrolling):

Note

You can control the reset time with `binds:scroll_event_delay`.

### Switches[](#switches)

Switches are useful for binding events like closing and opening a laptop’s lid:

Warning

Systemd `HandleLidSwitch` settings in `logind.conf` may conflict with Hyprland’s laptop lid switch configurations.

Note

You can view your switches with `hyprctl devices`.

### Multiple binds to one key[](#multiple-binds-to-one-key)

You can trigger multiple actions with the same keybind by assigning it multiple times, with different `disapatcher`s and `param`s:

Warning

The keybinds will be executed top to bottom, in the order they were written in.

### Description[](#description)

You can describe your keybind with the `d` flag.  
Your description always goes in front of the `dispatcher`, and must not include commas (`,`)!

For example:

If you want to access your description you can use `hyprctl binds`.  
For more information have a look at [Using Hyprctl](https://wiki.hypr.land/Configuring/Using-hyprctl).

## Mouse Binds[](#mouse-binds)

These are binds that rely on mouse movement. They will have one less arg.  
`binds:drag_threshold` can be used to differentiate between clicks and drags with the same button:

Available mouse binds:

NameDescriptionParamsmovewindowmoves the active windowNoneresizewindowresizes the active window`1` -&gt; Resize and keep window aspect ratio.  
`2` -&gt; Resize and ignore `keepaspectratio` window rule/prop.  
None or anything else for normal resize

Common mouse button key codes (check `wev` for other buttons):

Note

Mouse binds, despite their name, behave like normal binds.  
You are free to use whatever keys / mods you please. When held, the mouse function will be activated.

### Touchpad[](#touchpad)

As clicking and moving the mouse on a touchpad is unergonomic, you can also use keyboard keys instead of mouse clicks.

## Global Keybinds[](#global-keybinds)

### Classic[](#classic)

Yes, you heard this right, Hyprland does support global keybinds for *ALL* apps, including OBS, Discord, Firefox, etc.

See the [`pass`](https://wiki.hypr.land/Configuring/Dispatchers/#list-of-dispatchers) and [`sendshortcut`](https://wiki.hypr.land/Configuring/Dispatchers/#list-of-dispatchers) dispatchers for keybinds.

Let’s take OBS as an example: the “Start/Stop Recording” keybind is set to SUPER + F10, to make it work globally, simply add:

to your config and you’re done.

`pass` will pass the `PRESS` and `RELEASE` events by itself, no need for a `bindr`.  
This also means that push-to-talk will work flawlessly with one `pass`, e.g.:

You may also add shortcuts, where other keys are passed to the window.

Warning

This works flawlessly with all native Wayland applications, however, XWayland is a bit wonky.  
Make sure that what you’re passing is a “global Xorg keybind”, otherwise passing from a different XWayland app may not work.

### DBus Global Shortcuts[](#dbus-global-shortcuts)

Some applications may already support the GlobalShortcuts portal in xdg-desktop-portal.  
If that’s the case, it’s recommended to use the following method instead of `pass`:

Open your desired app and run `hyprctl globalshortcuts` in a terminal.  
This will give you a list of currently registered shortcuts with their description(s).

Choose whichever you like, for example `coolApp:myToggle`, and bind it to whatever you want with the `global` dispatcher:

Note

Please note that this function will *only* work with [XDPH](https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland).

## Submaps[](#submaps)

Keybind submaps, also known as *modes* or *groups*, allow you to activate a separate set of keybinds.  
For example, if you want to enter a `resize` *mode* that allows you to resize windows with the arrow keys, you can do it like this:

Warning

Do not forget a keybind (`escape`, in this case) to reset the keymap while inside it!

If you get stuck inside a keymap, you can use `hyprctl dispatch submap reset` to go back.  
If you do not have a terminal open, tough luck buddy. You have been warned.

You can also set the same keybind to perform multiple actions, such as resize and close the submap, like so:

This works because the binds are executed in the order they appear, and assigning multiple actions per bind is possible.

You can set a keybind that will be active no matter the current submap with the submap universal bind flag.

### Nesting[](#nesting)

Submaps can be nested, see the following example:

### Automatically close a submap on dispatch[](#automatically-close-a-submap-on-dispatch)

Submaps can be automatically closed or sent to another submap by appending `,` followed by a submap or *reset*.

### Catch-All[](#catch-all)

You can also define a keybind via the special `catchall` keyword, which activates no matter which key is pressed.  
This can be used to prevent any keys from passing to your active application while in a submap or to exit it immediately when any unknown key is pressed:

## Example Binds[](#example-binds)

### Media[](#media)

These binds set the expected behavior for regular keyboard media volume keys, including when the screen is locked: