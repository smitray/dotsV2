---
title: Monitors
url: https://wiki.hypr.land/Configuring/Monitors/
source: sitemap
fetched_at: 2026-02-01T09:22:33.391564021-03:00
rendered_js: false
word_count: 1158
summary: This document provides comprehensive configuration guidance for Hyprland monitor settings, covering display positioning, resolution options, scaling, rotation, and advanced features like HDR support and VRR.
tags:
    - monitor-config
    - display-settings
    - hyprland
    - screen-layout
    - resolution
    - scaling
    - graphics
    - configuration
category: reference
---

## General[](#general)

The general config of a monitor looks like this:

A common example:

This will make the monitor on `DP-1` a `1920x1080` display, at 144Hz, `0x0` off from the top left corner, with a scale of 1 (unscaled).

To list all available monitors (active and inactive):

Monitors are positioned on a virtual “layout”. The `position` is the position, in pixels, of said display in the layout. (calculated from the top-left corner)

For example:

will tell Hyprland to put DP-1 on the *left* of DP-2, while

will tell Hyprland to put DP-1 on the *right*.

The `position` may contain *negative* values, so the above example could also be written as

Hyprland uses an inverse Y cartesian system. Thus, a negative y coordinate places a monitor higher, and a positive y coordinate will place it lower.

For example:

will tell Hyprland to put DP-2 *above* DP-1, while

will tell Hyprland to put DP-2 *below*.

Note

The position is calculated with the scaled (and transformed) resolution, meaning if you want your 4K monitor with scale 2 to the left of your 1080p one, you’d use the position `1920x0` for the second screen (3840 / 2). If the monitor is also rotated 90 degrees (vertical), you’d use `1080x0`.

Warning

No monitors can overlap. This means that if your set positions make any monitors overlap, you will get a warning.

Leaving the name empty will define a fallback rule to use when no other rules match.

There are a few special values for the resolutions:

- `preferred` - use the display’s preferred size and refresh rate.
- `highres` - use the highest supported resolution.
- `highrr` - use the highest supported refresh rate.
- `maxwidth` - use the widest supported resolution.

Position also has a few special values:

- `auto` - let Hyprland decide on a position. By default, it places each new monitor to the right of existing ones, using the monitor’s top left corner as the root point.
- `auto-right/left/up/down` - place the monitor to the right/left, above or below other monitors, also based on each monitor’s top left corner as the root.
- `auto-center-right/left/up/down` - place the monitor to the right/left, above or below other monitors, but calculate placement from each monitor’s center rather than its top left corner.

***Please Note:*** While specifying a monitor direction for your first monitor is allowed, this does nothing and it will be positioned at (0,0). Also, the direction is always from the center out, so you can specify `auto-up` then `auto-left`, but the left monitors will just be left of the origin and above the origin. You can also specify duplicate directions and monitors will continue to go in that direction.

You can also use `auto` as a scale to let Hyprland decide on a scale for you. These depend on the PPI of the monitor.

Recommended rule for quickly plugging in random monitors:

This will make any monitor that was not specified with an explicit rule automatically placed on the right of the other(s), with its preferred resolution.

For more specific rules, you can also use the output’s description (see `hyprctl monitors` for more details). If the output of `hyprctl monitors` looks like the following:

then the `description` value up to, but not including the portname `(eDP-1)` can be used to specify the monitor:

Remember to remove the `(portname)`!

### Custom modelines[](#custom-modelines)

You can set up a custom modeline by changing the resolution field to a modeline, for example:

### Disabling a monitor[](#disabling-a-monitor)

To disable a monitor, use

Warning

Disabling a monitor will literally remove it from the layout, moving all windows and workspaces to any remaining ones. If you want to disable your monitor in a screensaver style (just turn off the monitor) use the `dpms` [dispatcher](https://wiki.hypr.land/Configuring/Dispatchers).

## Custom reserved area[](#custom-reserved-area)

A reserved area is an area that remains unoccupied by tiled windows. If your workflow requires a custom reserved area, you can add it with:

Where `TOP` `BOTTOM` `LEFT` `RIGHT` are integers, i.e the number in pixels of the reserved area to add. This does stack on top of the calculated reserved area (e.g. bars), but you may only use one of these rules per monitor in the config.

## Extra args[](#extra-args)

You can combine extra arguments at the end of the monitor rule, examples:

See below for more details about each argument.

### Mirrored displays[](#mirrored-displays)

If you want to mirror a display, add a `, mirror, <NAME>` at the end of the monitor rule, examples:

Please remember that mirroring displays will not “re-render” everything for your second monitor, so if mirroring a 1080p screen onto a 4K one, the resolution will still be 1080p on the 4K display. This also means squishing and stretching will occur on aspect ratios that differ (e.g 16:9 and 16:10).

### 10 bit support[](#10-bit-support)

If you want to enable 10 bit support for your display, add a `, bitdepth, 10` at the end of the monitor rule, e.g:

Warning

Colors registered in Hyprland (e.g. the border color) do *not* support 10 bit.  
Some applications do *not* support screen capture with 10 bit enabled.

### Color management presets[](#color-management-presets)

Add a `, cm, X` to change default sRGB output preset

Fullscreen HDR is possible without hdr `cm` setting if `render:cm_fs_passthrough` is enabled.

Use `sdrbrightness, B` and `sdrsaturation, S` to control SDR brightness and saturation in HDR mode. The default for both values is `1.0`. Typical brightness value should be in `1.0 ... 2.0` range.

The default transfer function assumed to be in use on an SDR display for sRGB content is defined by `, sdr_eotf, X`. The default (`0`) is to follow `render:cm_sdr_eotf`. This can be changed to piecewise sRGB with `1`, or Gamma 2.2 with `2`.

### VRR[](#vrr)

Per-display VRR can be done by adding `, vrr, X` where `X` is the mode from the [variables page](https://wiki.hypr.land/Configuring/Variables).

## Rotating[](#rotating)

If you want to rotate a monitor, add a `, transform, X` at the end of the monitor rule, where `X` corresponds to a transform number, e.g.:

Transform list:

## Monitor v2[](#monitor-v2)

Alternative syntax. `monitor = DP-1,1920x1080@144,0x0,1,transform,2` is the same as

The `disable` flag turns into `disabled = true`, but other named settings keep their names: `name, value` → `name = value` (e.g. `bitdepth,10` → `bitdepth = 10`)

EDID overrides and SDR → HDR settings:

namedescriptiontypesupports\_wide\_colorForce wide color gamut support (0 - auto, 1 - force on, -1 - force off)intsupports\_hdrForce HDR support. Requires wide color gamut (0 - auto, 1 - force on, -1 - force off)intsdr\_min\_luminanceSDR minimum lumninace used for SDR → HDR mapping. Set to 0.005 for true black matching HDR blackfloatsdr\_max\_luminanceSDR maximum luminance. Can be used to adjust overall SDR → HDR brightness. 80 - 400 is a reasonable range. The desired value is likely between 200 and 250intmin\_luminanceMonitor’s minimum luminancefloatmax\_luminanceMonitor’s maximum possible luminanceintmax\_avg\_luminanceMonitor’s maximum luminance on average for a typical frameint

Note: those values might get passed to the monitor itself and cause increased burn-in or other damage if it’s firmware lacks some safety checks.

## Default workspace[](#default-workspace)

See [Workspace Rules](https://wiki.hypr.land/Configuring/Workspace-Rules).

### Binding workspaces to a monitor[](#binding-workspaces-to-a-monitor)

See [Workspace Rules](https://wiki.hypr.land/Configuring/Workspace-Rules).