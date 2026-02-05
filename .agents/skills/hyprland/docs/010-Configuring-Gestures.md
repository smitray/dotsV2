---
title: Gestures
url: https://wiki.hypr.land/Configuring/Gestures/
source: sitemap
fetched_at: 2026-02-01T09:22:57.26173726-03:00
rendered_js: false
word_count: 189
summary: This document explains how to configure and use trackpad gestures in Hyprland, covering supported directions, actions, and gesture flags.
tags:
    - trackpad
    - gestures
    - hyprland
    - configuration
    - input
category: guide
---

## General[](#general)

Hyprland supports 1:1 gestures for the trackpad for some operations. The basic syntax looks like this:

Various actions may have their own options, or none. You can drop the options altogether and end on the action arg if the action takes none.

You can also restrict gestures to a modifier by adding `, mod: [MODMASK]` after `direction`, or scale the animation’s speed by a float by adding `scale: [SCALE]`.

Examples:

### Directions[](#directions)

The following directions are supported:

`direction`Description`swipe`any swipe`horizontal`horizontal swipe`vertical`vertical swipe`left`, `right`, `up`, `down`swipe directions`pinch`any pinch`pinchin`, `pinchout`directional pinch

### Actions[](#actions)

Specifying `unset` as the action will unset a specific gesture that was previously set. Please note it needs to exactly match everything from the original gesture including direction, mods, fingers and scale.

`action`DescriptionArguments`dispatcher`the most basic, executes a dispatcher once the gesture ends`dispatcher, params``workspace`workspace swipe gesture, for switching workspaces`move`moves the active windownone`resize`resizes the active windownone`special`toggles a special workspacespecial workspace without the `special:`, e.g. `mySpecialWorkspace``close`closes the active windownone`fullscreen`fullscreens the active windownone for fullscreen, `maximize` for maximize`float`floats the active windownone for toggle, `float` or `tile` for one-way

### Flags[](#flags)

Gestures support flags though the syntax:

Supported flags:

FlagNameDescription`p`bypassAllows the gesture to bypass shortcut inhibitors.