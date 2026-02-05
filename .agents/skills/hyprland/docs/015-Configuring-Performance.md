---
title: Performance
url: https://wiki.hypr.land/Configuring/Performance/
source: sitemap
fetched_at: 2026-02-01T09:23:22.805986435-03:00
rendered_js: false
word_count: 196
summary: Provides performance optimization tips and troubleshooting solutions for Hyprland users experiencing graphics issues, low FPS, battery drain, and gaming problems on various hardware configurations.
tags:
    - hyprland
    - performance-optimization
    - graphics
    - power-saving
    - gamescope
    - intel-igpu
    - wayland
category: guide
---

This page documents known tricks and fixes to boost performance if by any chance you stumble upon problems or you do not care that much about animations.

## Fractional scaling[](#fractional-scaling)

Wayland fractional scaling is a lot better than before, but it is not perfect. Some applications do not support it yet or the support is experimental at best. If you have problems with your graphics card having high usage or Hyprland feeling laggy, try setting the scaling to integer numbers such as `1` or `2` like in this example `monitor=,preferred,auto,2`.

## Low FPS/stutter/FPS drops on Intel iGPU with TLP (mainly laptops)[](#low-fpsstutterfps-drops-on-intel-igpu-with-tlp-mainly-laptops)

The TLP defaults are rather aggressive, setting `INTEL_GPU_MIN_FREQ_ON_AC` and/or `INTEL_GPU_MIN_FREQ_ON_BAT` in `/etc/tlp.conf` to something slightly higher (e.g. to 500 from 300) will reduce stutter significantly or, in the best case, remove it completely.

## How do I make Hyprland draw as little power as possible on my laptop?[](#how-do-i-make-hyprland-draw-as-little-power-as-possible-on-my-laptop)

***Useful Optimizations***:

- `decoration:blur:enabled = false` and `decoration:shadow:enabled = false` to disable fancy but battery hungry effects.
- `misc:vfr = true`, since it’ll lower the amount of sent frames when nothing is happening on-screen.

## My games work poorly, especially proton ones[](#my-games-work-poorly-especially-proton-ones)

Using `gamescope` tends to fix any and all issues with Wayland/Hyprland.