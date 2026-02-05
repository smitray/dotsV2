---
title: Master Layout
url: https://wiki.hypr.land/Configuring/Master-Layout/
source: sitemap
fetched_at: 2026-02-01T09:23:12.671339399-03:00
rendered_js: false
word_count: 790
summary: This document explains the configuration options and functionality of the master layout plugin for window management, including settings for master/slave window arrangement and associated dispatchers.
tags:
    - window-management
    - layout
    - master-layout
    - configuration
    - tiling
category: reference
---

The master layout makes one (or more) window(s) be the “master”, taking (by default) the left part of the screen, and tiles the rest on the right. You can change the orientation on a per-workspace basis if you want to use anything other than the default left/right split.

![master1](https://user-images.githubusercontent.com/43317083/179357849-321f042c-f536-44b3-9e6f-371df5321836.gif)

## Config[](#config)

*category name `master`*

namedescriptiontypedefaultallow\_small\_splitenable adding additional master windows in a horizontal split styleboolfalsespecial\_scale\_factorthe scale of the special workspace windows. \[0.0 - 1.0]float1mfactthe size as a percentage of the master window, for example `mfact = 0.70` would mean 70% of the screen will be the master window, and 30% the slave \[0.0 - 1.0]floatvalue0.55new\_status`master`: new window becomes master; `slave`: new windows are added to slave stack; `inherit`: inherit from focused windowstring`slave`new\_on\_topwhether a newly open window should be on the top of the stackboolfalsenew\_on\_active`before`, `after`: place new window relative to the focused window; `none`: place new window according to the value of `new_on_top`.string`none`orientationdefault placement of the master area, can be left, right, top, bottom or centerstringleftslave\_count\_for\_center\_masterwhen using orientation=center, make the master window centered only when at least this many slave windows are open. (Set 0 to always\_center\_master)int2center\_master\_fallbackSet fallback for center master when slaves are less than slave\_count\_for\_center\_master, can be left ,right ,top ,bottomstringleftsmart\_resizingif enabled, resizing direction will be determined by the mouse’s position on the window (nearest to which corner). Else, it is based on the window’s tiling position.booltruedrop\_at\_cursorwhen enabled, dragging and dropping windows will put them at the cursor position. Otherwise, when dropped at the stack side, they will go to the top/bottom of the stack depending on new\_on\_top.booltruealways\_keep\_positionwhether to keep the master window in its configured position when there are no slave windowsboolfalse

## Dispatchers[](#dispatchers)

`layoutmsg` commands:

commanddescriptionparamsswapwithmasterswaps the current window with master. If the current window is the master, swaps it with the first child.either `master` (new focus is the new master window), `child` (new focus is the new child) or `auto` (which is the default, keeps the focus of the previously focused window). Adding `ignoremaster` will ignore this dispatcher if master is already focused.focusmasterfocuses the master window.either `master` (focus stays on master), `auto` (default; focus first non-master window if already on master) or `previous` (remember current window when focusing master, if already on master, focus previous or fallback to `auto`).cyclenextfocuses the next window respecting the layouteither `loop` (allow looping from the bottom of the pile back to master) or `noloop` (force stop at the bottom of the pile, like in DWM). `loop` is the default if left blank.cycleprevfocuses the previous window respecting the layouteither `loop` (allow looping from master to the bottom of the pile) or `noloop` (force stop at master, like in DWM). `loop` is the default if left blank.swapnextswaps the focused window with the next window respecting the layouteither `loop` (allow swapping the bottom of the pile and master) or `noloop` (do not allow it, like in DWM). `loop` is the default if left blank.swapprevswaps the focused window with the previous window respecting the layouteither `loop` (allow swapping master and the bottom of the pile) or `noloop` (do not allow it, like in DWM). `loop` is the default if left blank.addmasteradds a master to the master side. That will be the active window, if it’s not a master, or the first non-master window.noneremovemasterremoves a master from the master side. That will be the active window, if it’s a master, or the last master window.noneorientationleftsets the orientation for the current workspace to left (master area left, slave windows to the right, vertically stacked)noneorientationrightsets the orientation for the current workspace to right (master area right, slave windows to the left, vertically stacked)noneorientationtopsets the orientation for the current workspace to top (master area top, slave windows to the bottom, horizontally stacked)noneorientationbottomsets the orientation for the current workspace to bottom (master area bottom, slave windows to the top, horizontally stacked)noneorientationcentersets the orientation for the current workspace to center (master area center, slave windows alternate to the left and right, vertically stacked)noneorientationnextcycle to the next orientation for the current workspace (clockwise)noneorientationprevcycle to the previous orientation for the current workspace (counter-clockwise)noneorientationcyclecycle to the next orientation from the provided list, for the current workspaceallowed values: `left`, `top`, `right`, `bottom`, or `center`. The values have to be separated by a space. If left empty, it will work like `orientationnext`mfactchange mfact, the master split ratiothe new split ratio, a relative float delta (e.g `-0.2` or `+0.2`) or `exact` followed by a the exact float value between 0.0 and 1.0rollnextrotate the next window in stack to be the master, while keeping the focus on masternonerollprevrotate the previous window in stack to be the master, while keeping the focus on masternone

Parameters for the commands are separated by a single space.

## Workspace Rules[](#workspace-rules)

`layoutopt` rules:

ruledescriptiontypeorientation:\[o]Sets the orientation of a workspace. For available orientations, see [Config-&gt;orientation](#config)string

Example usage: