---
title: hypridle
url: https://wiki.hypr.land/Hypr-Ecosystem/hypridle/
source: sitemap
fetched_at: 2026-02-01T09:22:30.908593929-03:00
rendered_js: false
word_count: 316
summary: This document provides configuration instructions and usage guidelines for hypridle, Hyprland's idle management daemon that handles session locking, unlocking, and sleep inhibition events.
tags:
    - hyprland
    - idle-management
    - session-lock
    - sleep-inhibition
    - configuration-file
    - dbus-events
    - wayland
category: guide
---

[hypridle](https://github.com/hyprwm/hypridle) is Hyprland’s idle management daemon.

## Configuration[](#configuration)

Configuration is done via the config file at `~/.config/hypr/hypridle.conf`.  
A config file is required; hypridle won’t run without one.  
To run hypridle at startup, edit `hyprland.conf` and add: `exec-once = hypridle`.  
If Hyprland is started with [uwsm](https://wiki.hypr.land/Useful-Utilities/Systemd-start), you can use `systemctl --user enable --now hypridle.service`.

### General[](#general)

Variables in the `general` category:

VariableDescriptionTypeDefault`lock_cmd`command to run when receiving a dbus lock event (e.g. `loginctl lock-session`)stringempty`unlock_cmd`command to run when receiving a dbus unlock event (e.g. `loginctl unlock-session`)stringempty`on_lock_cmd`command to run when the session gets locked by a lock screen appstringempty`on_unlock_cmd`command to run when the session gets unlocked by a lock screen appstringempty`before_sleep_cmd`command to run when receiving a dbus prepare\_sleep eventstringempty`after_sleep_cmd`command to run when receiving a dbus post prepare\_sleep eventstringempty`ignore_dbus_inhibit`whether to ignore dbus-sent idle inhibit events (e.g. from firefox)bool`false``ignore_systemd_inhibit`whether to ignore `systemd-inhibit --what=idle` inhibitorsbool`false``ignore_wayland_inhibit`whether to ignore Wayland protocol idle inhibitorsbool`false``inhibit_sleep`sleep inhibition mode:  
`0`: disable  
`1`: normal  
`2`: auto  
`3`: lock notifyint`2`

Note

The `general:inhibit_sleep` option is used to make sure hypridle can perform certain tasks before the system goes to sleep.

Options:

- `0` disables sleep inhibition.
- `1` makes the system wait until hypridle launched `general:before_sleep_cmd`.
- `2` (auto) selects either `3` or `1` depending on whether hypridle detects if you want to launch hyprlock before sleep.
- `3` makes your system wait until the session gets locked by a lock screen app. This works with all wayland session-lock apps.

### Listeners[](#listeners)

Hypridle uses listeners to define actions on idleness.

Every listener has a *timeout* (in seconds). After idling for *timeout* seconds, `on-timeout` will fire.  
When action is resumed after idle, `on-resume` will fire.

Example listener:

You can define as many listeners as you want.

Variables in the `listener` category:

variabledescriptiontypedefault`timeout`Idle time in seconds.intnone, value must be specified`on-timeout`Command to run when timeout has passed.stringempty`on-resume`Command to run when activity is detected after timeout has fired.stringempty`ignore_inhibit`Ignore idle inhibitors (of all types) for this rule.bool`false`

### Examples[](#examples)

Full hypridle example with hyprlock: