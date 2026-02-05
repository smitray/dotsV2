---
title: Expanding functionality
url: https://wiki.hypr.land/Configuring/Expanding-functionality/
source: sitemap
fetched_at: 2026-02-01T09:23:16.865195186-03:00
rendered_js: false
word_count: 67
summary: This document explains how to use Hyprland's IPC sockets for automation and event handling, specifically detailing socket1 for control commands and socket2 for receiving events.
tags:
    - hyprland
    - ipc
    - sockets
    - automation
    - bash-scripting
    - window-manager
category: reference
---

Hyprland exposes two powerful sockets for you to use.

The first, socket1, can be fully controlled with `hyprctl`, see its usage [here](https://wiki.hypr.land/Configuring/Using-hyprctl).

The second, socket2, sends events for certain changes / actions and can be used to react to different events. See its description [here](https://wiki.hypr.land/IPC/).

## Example script[](#example-script)

This bash script will change the outer gaps to 20 if the currently focused monitor is DP-1, and 30 otherwise.

```
#!/usr/bin/env bash
function handle {
  if [[ ${1:0:10} == "focusedmon" ]]; then
    if [[ ${1:12:4} == "DP-1" ]]; then
      hyprctl keyword general:gaps_out 20
    else
      hyprctl keyword general:gaps_out 30
    fi
  fi
}
socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do handle "$line"; done
```