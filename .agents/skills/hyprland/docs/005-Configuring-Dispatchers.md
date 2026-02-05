---
title: Dispatchers
url: https://wiki.hypr.land/Configuring/Dispatchers/
source: sitemap
fetched_at: 2026-02-01T09:22:39.824215759-03:00
rendered_js: false
word_count: 1842
summary: This document provides comprehensive documentation for Hyprland window management dispatchers and their parameters, explaining how to control windows, workspaces, and system behavior through various commands.
tags:
    - window-management
    - hyprland
    - dispatchers
    - keybindings
    - workspaces
    - tiling-window-manager
    - configuration
    - linux-desktop
category: reference
---

Please keep in mind some layout-specific dispatchers will be listed in the layout pages (See the sidebar).

## Parameter explanation[](#parameter-explanation)

Param typeDescriptionwindowa window. Any of the following: class regex (by default, optionally `class:`), `initialclass:` initial class regex, `title:` title regex, `initialtitle` initial title regex, `tag:` window tag regex, `pid:` the pid, `address:` the address, `activewindow` an active window, `floating` the first floating window on the current workspace, `tiled` the first tiled window on the current workspaceworkspacesee [below](#workspaces).direction`l` `r` `u` `d` left right up downmonitorOne of: direction, ID, name, `current`, relative (e.g. `+1` or `-1`)resizeparamsrelative pixel delta vec2 (e.g. `10 -10`), optionally a percentage of the window size (e.g. `20 25%`) or `exact` followed by an exact vec2 (e.g. `exact 1280 720`), optionally a percentage of the screen size (e.g. `exact 50% 50%`)floatvaluea relative float delta (e.g `-0.2` or `+0.2`) or `exact` followed by a the exact float value (e.g. `exact 0.5`)zheight`top` or `bottom`mod`SUPER`, `SUPER_ALT`, etc.key`g`, `code:42`, `42` or mouse clicks (`mouse:272`)

## List of Dispatchers[](#list-of-dispatchers)

DispatcherDescriptionParamsexecexecutes a shell commandcommand (supports rules, see [below](#executing-with-rules))execrexecutes a raw shell command (does not support rules)commandpasspasses the key (with mods) to a specified window. Can be used as a workaround to global keybinds not working on Wayland.windowsendshortcutsends specified keys (with mods) to an optionally specified window. Can be used like passmod, key\[, window]sendkeystateSend a key with specific state (down/repeat/up) to a specified window (window must keep focus for events to continue).mod, key, state, windowkillactivecloses (not kills) the active windownoneforcekillactivekills the active windownoneclosewindowcloses a specified windowwindowkillwindowkills a specified windowwindowsignalsends a signal to the active windowsignalsignalwindowsends a signal to a specified window`window,signal`, e.g.`class:Alacritty,9`workspacechanges the workspaceworkspacemovetoworkspacemoves the focused window to a workspaceworkspace OR `workspace,window` for a specific windowmovetoworkspacesilentsame as above, but doesn’t switch to the workspaceworkspace OR `workspace,window` for a specific windowtogglefloatingtoggles the current window’s floating stateleft empty / `active` for current, or `window` for a specific windowsetfloatingsets the current window’s floating state to trueleft empty / `active` for current, or `window` for a specific windowsettiledsets the current window’s floating state to falseleft empty / `active` for current, or `window` for a specific windowfullscreensets the focused window’s fullscreen mode`mode action`, where mode can be 0 - fullscreen (takes your entire screen) or 1 - maximize (keeps gaps and bar(s)), while action is optional and can be `toggle` (default), `set` or `unset`.fullscreenstatesets the focused window’s fullscreen mode and the one sent to the client`internal client action`, where internal (the hyprland window) and client (the application) can be `-1` - current, `0` - none, `1` - maximize, `2` - fullscreen, `3` - maximize and fullscreen. action is optional and can be `toggle` (default) or `set`.dpmssets all monitors’ DPMS status. Do not use with a keybind directly.`on`, `off`, or `toggle`. For specific monitor add monitor name after a spaceforceidlesets elapsed time for all idle timers, ignoring idle inhibitors. Timers return to normal behavior upon the next activity. Do not use with a keybind directly.floatvalue (number of seconds)pinpins a window (i.e. show it on all workspaces) *note: floating only*left empty / `active` for current, or `window` for a specific windowmovefocusmoves the focus in a directiondirectionmovewindowmoves the active window in a direction or to a monitor. For floating windows, moves the window to the screen edge in that directiondirection or `mon:` and a monitor, optionally followed by a space and `silent` to prevent the focus from moving with the windowswapwindowswaps the active window with another window in the given direction or with a specific windowdirection or `window`centerwindowcenter the active window *note: floating only*none (for monitor center) or 1 (to respect monitor reserved area)resizeactiveresizes the active windowresizeparamsmoveactivemoves the active windowresizeparamsresizewindowpixelresizes a selected window`resizeparams,window`, e.g. `100 100,^(kitty)$`movewindowpixelmoves a selected window`resizeparams,window`cyclenextfocuses the next window (on a workspace, if `visible` is not provided)none (for next) or `prev` (for previous) additionally `tiled` for only tiled, `floating` for only floating. `prev tiled` is ok. `visible` for all monitors cycling. `visible prev floating` is ok. if `hist` arg provided - focus order will depends on focus history. All other modifiers is also working for it, `visible next floating hist` is ok.swapnextswaps the focused window with the next window on a workspacenone (for next) or `prev` (for previous)tagwindowapply tag to current or the first window matching`tag [window]`, e.g. `+code ^(foot)$`, `music`focuswindowfocuses the first window matchingwindowfocusmonitorfocuses a monitormonitorsplitratiochanges the split ratiofloatvaluemovecursortocornermoves the cursor to the corner of the active windowdirection, 0 - 3, bottom left - 0, bottom right - 1, top right - 2, top left - 3movecursormoves the cursor to a specified position`x y`renameworkspacerename a workspace`id name`, e.g. `2 work`exitexits the compositor with no questions asked. It’s recommended to use `hyprshutdown` instead of this.noneforcerendererreloadforces the renderer to reload all resources and outputsnonemovecurrentworkspacetomonitorMoves the active workspace to a monitormonitorfocusworkspaceoncurrentmonitorFocuses the requested workspace on the current monitor, swapping the current workspace to a different monitor if necessary. If you want XMonad/Qtile-style workspace switching, replace `workspace` in your config with this.workspacemoveworkspacetomonitorMoves a workspace to a monitorworkspace and a monitor separated by a spaceswapactiveworkspacesSwaps the active workspaces between two monitorstwo monitors separated by a spacebringactivetotop*Deprecated* in favor of alterzorder. Brings the current window to the top of the stacknonealterzorderModify the window stack order of the active or specified window. Note: this cannot be used to move a floating window behind a tiled one.zheight\[,window]togglespecialworkspacetoggles a special workspace on/offnone (for the first) or name for named (name has to be a special workspace’s name)focusurgentorlastFocuses the urgent window or the last windownonetogglegrouptoggles the current active window into a groupnonechangegroupactiveswitches to the next window in a group.b - back, f - forward, or index start at 1focuscurrentorlastSwitch focus from current to previously focused windownonelockgroupsLocks the groups (all groups will not accept new windows)`lock` for locking, `unlock` for unlocking, `toggle` for togglelockactivegroupLock the focused group (the current group will not accept new windows or be moved to other groups)`lock` for locking, `unlock` for unlocking, `toggle` for togglemoveintogroupMoves the active window into a group in a specified direction. No-op if there is no group in the specified direction.directionmoveoutofgroupMoves the active window out of a group. No-op if not in a groupleft empty / `active` for current, or `window` for a specific windowmovewindoworgroupBehaves as `moveintogroup` if there is a group in the given direction. Behaves as `moveoutofgroup` if there is no group in the given direction relative to the active group. Otherwise behaves like `movewindow`.directionmovegroupwindowSwaps the active window with the next or previous in a group`b` for back, anything else for forwarddenywindowfromgroupProhibit the active window from becoming or being inserted into group`on`, `off` or, `toggle`setignoregrouplockTemporarily enable or disable binds:ignore\_group\_lock`on`, `off`, or `toggle`globalExecutes a Global Shortcut using the GlobalShortcuts portal. See [here](https://wiki.hypr.land/Configuring/Binds/#global-keybinds)namesubmapChange the current mapping group. See [Submaps](https://wiki.hypr.land/Configuring/Binds/#submaps)`reset` or nameeventEmits a custom event to socket2 in the form of `custom>>yourdata`the data to sendsetpropSets a window property`window property value`toggleswallowIf a window is swallowed by the focused window, unswallows it. Execute again to swallow it backnone

Warning

[uwsm](https://wiki.hypr.land/Useful-Utilities/Systemd-start) users should avoid using `exit` dispatcher, or terminating Hyprland process directly, as exiting Hyprland this way removes it from under its clients and interferes with ordered shutdown sequence. Use `exec, uwsm stop` (or [other variants](https://github.com/Vladimir-csp/uwsm#how-to-stop)) which will gracefully bring down graphical session (and login session bound to it, if any). If you experience problems with units entering inconsistent states, affecting subsequent sessions, use `exec, loginctl terminate-user ""` instead (terminates all units of the user).

It’s also strongly advised to replace the `exit` dispatcher inside `hyprland.conf` keybinds section accordingly.

Warning

It is NOT recommended to set DPMS or forceidle with a keybind directly, as it might cause undefined behavior. Instead, consider something like

### Grouped (tabbed) windows[](#grouped-tabbed-windows)

Hyprland allows you to make a group from the current active window with the `togglegroup` bind dispatcher.

A group is like i3wm’s “tabbed” container. It takes the space of one window, and you can change the window to the next one in the tabbed “group” with the `changegroupactive` bind dispatcher.

The new group’s border colors are configurable with the appropriate `col.` settings in the `group` config section.

You can lock a group with the `lockactivegroup` dispatcher in order to stop new windows from entering this group. In addition, the `lockgroups` dispatcher can be used to toggle an independent global group lock that will prevent new windows from entering any groups, regardless of their local group lock stat.

You can prevent a window from being added to a group or becoming a group with the `denywindowfromgroup` dispatcher. `movewindoworgroup` will behave like `movewindow` if the current active window or window in direction has this property set.

## Workspaces[](#workspaces)

You have nine choices:

- ID: e.g. `1`, `2`, or `3`
- Relative ID: e.g. `+1`, `-3` or `+100`
- workspace on monitor, relative with `+` or `-`, absolute with `~`: e.g. `m+1`, `m-2` or `m~3`
- workspace on monitor including empty workspaces, relative with `+` or `-`, absolute with `~`: e.g. `r+1` or `r~3`
- open workspace, relative with `+` or `-`, absolute with `~`: e.g. `e+1`, `e-10`, or `e~2`
- Name: e.g. `name:Web`, `name:Anime` or `name:Better anime`
- Previous workspace: `previous`, or `previous_per_monitor`
- First available empty workspace: `empty`, suffix with `m` to only search on monitor. and/or `n` to make it the *next* available empty workspace. e.g. `emptynm`
- Special Workspace: `special` or `special:name` for named special workspaces.

Warning

`special` is supported ONLY on `movetoworkspace` and `movetoworkspacesilent`.  
Any other dispatcher will result in undocumented behavior.

Warning

Numerical workspaces (e.g. `1`, `2`, `13371337`) are allowed **ONLY** between 1 and 2147483647 (inclusive).  
Neither `0` nor negative numbers are allowed.

## Special Workspace[](#special-workspace)

A special workspace is what is called a “scratchpad” in some other places. A workspace that you can toggle on/off on any monitor.

Note

You can define multiple named special workspaces, but the amount of those is limited to 97 at a time.

For example, to move a window/application to a special workspace you can use the following syntax:

## Executing with rules[](#executing-with-rules)

The `exec` dispatcher supports adding rules. Please note some windows might work better, some worse. It records the PID of the spawned process and uses that. For example, if your process forks and then the fork opens a window, this will not work.

The syntax is:

For example:

### setprop[](#setprop)

Props are any of the *dynamic effects* of [Window Rules](https://wiki.hypr.land/Configuring/Window-Rules#dynamic-effects).

For example:

Some props are expanded from their window rule parents which take multiple arguments:

- `border_color` -&gt; `active_border_color`, `inactive_border_color`
- `opacity` -&gt; `opacity`, `opacity_inactive`, `opacity_fullscreen`, `opacity_override`, `opacity_inactive_override`, `opacity_fullscreen_override`

### Fullscreenstate[](#fullscreenstate)

`fullscreenstate internal client`

The `fullscreenstate` dispatcher decouples the state that Hyprland maintains for a window from the fullscreen state that is communicated to the client.

`internal` is a reference to the state maintained by Hyprland.

`client` is a reference to the state that the application receives.

ValueStateDescription-1CurrentMaintains the current fullscreen state.0NoneWindow allocates the space defined by the current layout.1MaximizeWindow takes up the entire working space, keeping the margins.2FullscreenWindow takes up the entire screen.3Maximize and FullscreenThe state of a fullscreened maximized window. Works the same as fullscreen.

For example:

`fullscreenstate 2 0` Fullscreens the application and keeps the client in non-fullscreen mode.

This can be used to prevent Chromium-based browsers from going into presentation mode when they detect they have been fullscreened.

`fullscreenstate 0 2` Keeps the window non-fullscreen, but the client goes into fullscreen mode within the window.