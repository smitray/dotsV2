---
title: Other
url: https://wiki.hypr.land/Useful-Utilities/Other/
source: sitemap
fetched_at: 2026-02-01T09:23:01.347327691-03:00
rendered_js: false
word_count: 306
summary: This document provides a curated list of third-party projects and utilities that enhance Hyprland's functionality, covering workspace management, keyboard layouts, editor support, keybind management, IPC wrappers, screen shaders, wireless settings, and automatic mounting solutions.
tags:
    - hyprland
    - workspace-management
    - keyboard-layout
    - configuration
    - ipc-wrapper
    - screen-shader
    - wireless-settings
    - udiskie
category: reference
---

Here you will find links to some other projects that may not fit into any of the above categories.

### Workspace management[](#workspace-management)

[hyprsome](https://github.com/sopa0/hyprsome) by *sopa0*: Awesome-like workspaces for Hyprland.

### Keyboard layout management[](#keyboard-layout-management)

[hyprland-per-window-layout](https://github.com/coffebar/hyprland-per-window-layout/) by *MahouShoujoMivutilde and coffebar*: Per window keyboard layouts for Hyprland.

### Editor support for config files[](#editor-support-for-config-files)

[HyprLS](https://github.com/hyprland-community/hyprls) by *gwennlbh*: A LSP server to provide auto-completion and more for Hyprland’s configuration files in neovim, VS Code & others

### Keybind Management[](#keybind-management)

[hyprKCS](https://github.com/kosa12/hyprKCS) by *kosa12*: A fast, minimal Hyprland keybind manager written in Rust/GTK4.

### IPC wrappers[](#ipc-wrappers)

[hyprland-rs](https://github.com/yavko/hyprland-rs) by *yavko*: A neat wrapper for Hyprland’s IPC written in Rust.

### Screen shaders/color temperature[](#screen-shaderscolor-temperature)

- [hyprshade](https://github.com/loqusion/hyprshade) by *loqusion*: Utility for swapping and scheduling screen shaders; also functions as an [automatic color temperature shifter](https://en.wikipedia.org/wiki/F.lux).
- [gammastep](https://gitlab.com/chinstrap/gammastep) by *Chinstrap*: Control temperature color automatically depending on the time of the day and location.

### Wireless settings[](#wireless-settings)

- [iwgtk](https://github.com/J-Lentz/iwgtk) by *Jesse Lentz*: WiFi settings frontend for `iwd` in GTK
- [blueberry](https://github.com/linuxmint/blueberry) by *Linux Mint*: Bluetooth settings frontend in GTK
- [Overskride](https://github.com/kaii-lb/overskride) by *kaii-lb*: A simple yet powerful bluetooth client in GTK4
- [nm-applet](https://gitlab.gnome.org/GNOME/network-manager-applet) by *GNOME*: Applet for interfacing with NetworkManager in GTK

### Automatically Mounting Using `udiskie`[](#automatically-mounting-using-udiskie)

*Starting method:* manual (’exec-once')

USB mass storage devices, like thumb drives, mobile phones, digital cameras, etc. are not mounted automatically to the file system.

Typically, they have to be manually mounted, often using root and `umount` to do so.

Many popular DEs automatically handle this by using `udisks2` wrappers.

`udiskie` is a udisks2 front-end that allows to manage removable media such as CDs or flash drives from userspace.

Install `udiskie` via your package manager, or [build manually](https://github.com/coldfix/udiskie/wiki/installation)

Head over to your `hyprland.conf` and add the following line:

[See more uses here](https://github.com/coldfix/udiskie/wiki/Usage).

### Other useful utilities[](#other-useful-utilities)

The website [We Are Wayland Now](https://wearewaylandnow.com/) details some other useful utilities and applications for Wayland like docks, email clients, and so on, along with some other useful information about compatibility on Wayland.