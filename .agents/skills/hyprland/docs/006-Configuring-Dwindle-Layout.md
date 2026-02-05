---
title: Dwindle Layout
url: https://wiki.hypr.land/Configuring/Dwindle-Layout/
source: sitemap
fetched_at: 2026-02-01T09:23:05.390217264-03:00
rendered_js: false
word_count: 511
summary: This document explains the Dwindle layout system used in Hyprland, detailing its dynamic splitting behavior, configuration options, and available dispatchers for window management.
tags:
    - dwindle-layout
    - window-management
    - hyprland
    - bspwm
    - tiling-window-manager
    - configuration
    - layout-system
category: reference
---

Dwindle is a BSPWM-like layout, where every window on a workspace is a member of a binary tree.

## Quirks[](#quirks)

Dwindle splits are NOT PERMANENT. The split is determined dynamically with the W/H ratio of the parent node. If W &gt; H, it’s side-by-side. If H &gt; W, it’s top-and-bottom. You can make them permanent by enabling `preserve_split`.

## Config[](#config)

category name: `dwindle`

namedescriptiontypedefaultpseudotileenable pseudotiling. Pseudotiled windows retain their floating size when tiled.boolfalseforce\_split0 -&gt; split follows mouse, 1 -&gt; always split to the left (new = left or top) 2 -&gt; always split to the right (new = right or bottom)int0preserve\_splitif enabled, the split (side/top) will not change regardless of what happens to the container.boolfalsesmart\_splitif enabled, allows a more precise control over the window split direction based on the cursor’s position. The window is conceptually divided into four triangles, and cursor’s triangle determines the split direction. This feature also turns on preserve\_split.boolfalsesmart\_resizingif enabled, resizing direction will be determined by the mouse’s position on the window (nearest to which corner). Else, it is based on the window’s tiling position.booltruepermanent\_direction\_overrideif enabled, makes the preselect direction persist until either this mode is turned off, another direction is specified, or a non-direction is specified (anything other than l,r,u/t,d/b)boolfalsespecial\_scale\_factorspecifies the scale factor of windows on the special workspace \[0 - 1]float1split\_width\_multiplierspecifies the auto-split width multiplier. Multiplying window size is useful on widescreen monitors where window W &gt; H even after several splits.float1.0use\_active\_for\_splitswhether to prefer the active window or the mouse position for splitsbooltruedefault\_split\_ratiothe default split ratio on window open. 1 means even 50/50 split. \[0.1 - 1.9]float1.0split\_biasspecifies which window will receive the split ratio. 0 -&gt; directional (the top or left window), 1 -&gt; the current windowint0precise\_mouse\_movebindm movewindow will drop the window more precisely depending on where your mouse is.boolfalsesingle\_window\_aspect\_ratiowhenever only a single window is shown on a screen, add padding so that it conforms to the specified aspect ratio. A value like `4 3` on a 16:9 screen will make it a 4:3 window in the middle with padding to the sides.Vec2D0 0single\_window\_aspect\_ratio\_tolerancesets a tolerance for `single_window_aspect_ratio`, so that if the padding that would have been added is smaller than the specified fraction of the height or width of the screen, it will not attempt to adjust the window size \[0 - 1]int0.1

## Bind Dispatchers[](#bind-dispatchers)

dispatcherdescriptionparamspseudotoggles the given window’s pseudo modeleft empty / `active` for current, or `window` for a specific window

## Layout messages[](#layout-messages)

Dispatcher `layoutmsg` params:

paramdescriptionargstogglesplittoggles the split (top/side) of the current window. `preserve_split` must be enabled for toggling to work.noneswapsplitswaps the two halves of the split of the current window.nonepreselectA one-time override for the split direction. (valid for the next window to be opened, only works on tiled windows)directionmovetorootmoves the selected window (active window if unspecified) to the root of its workspace tree. The default behavior maximizes the window in its current subtree. If `unstable` is provided as the second argument, the window will be swapped with the other subtree instead. It is not possible to only provide the second argument, but `movetoroot active unstable` will achieve the same result.\[window, \[ string ]]

e.g.: