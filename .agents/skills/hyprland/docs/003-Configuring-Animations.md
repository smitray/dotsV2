---
title: Animations
url: https://wiki.hypr.land/Configuring/Animations/
source: sitemap
fetched_at: 2026-02-01T09:22:51.00321301-03:00
rendered_js: false
word_count: 278
summary: This document explains how to configure animations in Hyprland using the animation keyword, covering parameters like ONOFF, SPEED, CURVE, and STYLE, along with details about the animation tree and curve definitions.
tags:
    - animation
    - hyprland
    - bezier
    - curves
    - speed
    - style
    - tree
category: configuration
---

## General[](#general)

Animations are declared with the `animation` keyword.

`ONOFF` use `0` to disable, `1` to enable. *Note:* if it’s `0`, you can omit further args.

`SPEED` is the amount of ds (1ds = 100ms) the animation will take.

`CURVE` is the bezier curve name, see [curves](#curves).

`STYLE` (optional) is the animation style.

The animations are a tree. If an animation is unset, it will inherit its parent’s values. See [the animation tree](#animation-tree).

### Examples[](#examples)

### Animation tree[](#animation-tree)

Warning

Using the `loop` style for `borderangle` requires Hyprland to *constantly* render new frames at a frequency equal to your screen’s refresh rate (e.g. 60 times per second for a 60hz monitor), which might stress your CPU/GPU and will impact battery life.  
This will apply even if animations are disabled or borders are not visible.

## Curves[](#curves)

Defining your own [Bézier curve](https://en.wikipedia.org/wiki/B%C3%A9zier_curve) can be done with the `bezier` keyword:

where `NAME` is a name of your choice and `X0, Y0, X1, Y1` are the the two control points for a Cubic Bézier curve.  
A good website to design your own Bézier can be [cssportal.com](https://www.cssportal.com/css-cubic-bezier-generator/).  
If you want to instead choose from a list of pre-made Béziers, you can check out [easings.net](https://easings.net).

### Example[](#example)

### Extras[](#extras)

For animation style `popin` in `windows`, you can specify a minimum percentage to start from. For example, the following will make the animation 80% -&gt; 100% of the size:

For animation styles `slide`, `slidevert`, `slidefade` and `slidefadevert` in `workspaces`, you can specify a movement percentage. For example, the following will make windows move 20% of the screen width:

For animation style `slide` in `windows` and `layers` you can specify a forced side.  
You can choose between `top`, `bottom`, `left` or `right`.