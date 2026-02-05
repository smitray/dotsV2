---
title: Systemd startup
url: https://wiki.hypr.land/Useful-Utilities/Systemd-start/
source: sitemap
fetched_at: 2026-02-01T09:23:10.777937235-03:00
rendered_js: false
word_count: 307
summary: This document explains how to use Universal Wayland Session Manager (uwsm) to manage Wayland sessions with systemd, covering installation, launching compositors like Hyprland, running applications within the session, and setting up autostart functionality.
tags:
    - wayland
    - session-management
    - systemd
    - hyprland
    - desktop-environment
    - linux
category: guide
---

## UWSM[](#uwsm)

- [Universal Wayland Session Manager](https://github.com/Vladimir-csp/uwsm) wraps standalone Wayland compositors into a set of Systemd units and provides robust session management including environment, XDG autostart support, bi-directional binding with login session, and clean shutdown.

Please note uwsm is for advanced users and has its issues and additional quirks.

## Installation[](#installation)

**Arch**

**Nix/NixOS**

## Launching Hyprland with uwsm[](#launching-hyprland-with-uwsm)

### In tty[](#in-tty)

To launch Hyprland with uwsm, add this code in your shell profile.

This will bring uwsm compositor selection menu after you log in tty1. Choose `Hyprland` entry and you’re good to go.

If you want to bypass compositor selection menu and launch Hyprland directly, use this code in your shell profile, instead.

### Using a display manager[](#using-a-display-manager)

If you use a display manager, choose `Hyprland (uwsm-managed)` entry in a display manager selection menu.

## Launching applications inside session[](#launching-applications-inside-session)

The concept of a session managed by Systemd implies also running applications as units. Uwsm [provides](https://github.com/Vladimir-csp/uwsm#3-applications-and-slices) a helper to do it. Running applications as child processes inside compositor’s unit is discouraged.

Prefix application startup commands with `uwsm app --`. It also supports launching Desktop Entries by IDs or paths. See `man uwsm` or `uwsm app --help`.

Examples for autostart and bind entries:

Faster alternatives are:

- `uwsm-app`: a shell client working with on-demand daemon, optional part of uwsm.
- `app2unit`: ([link](https://github.com/Vladimir-csp/app2unit)), pure shell alternative, file opener, usually ahead on features.
- `runapp`: ([link](https://github.com/c4rlo/runapp/)), C++ alternative, even faster, features may vary.

## Autostart[](#autostart)

XDG Autostart is handled by systemd, and its target is activated in uwsm-managed session automatically.

Some applications provide native systemd user units to be autostarted with. Those might need to be enabled explicitly via `systemctl --user enable [some-app.service]`. Or, in case the unit is missing `[Install]` section, enabled more directly: `systemctl --user add-wants graphical-session.target [some-app.service]`. Also ensure the unit has `After=graphical-session.target` ordering (it can be added via drop-in).

More autostart-related examples and tricks can be found [here](https://github.com/Vladimir-csp/uwsm/tree/master/example-units).