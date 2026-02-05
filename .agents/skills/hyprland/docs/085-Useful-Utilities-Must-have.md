---
title: Must have
url: https://wiki.hypr.land/Useful-Utilities/Must-have/
source: sitemap
fetched_at: 2026-02-01T09:22:08.863924822-03:00
rendered_js: false
word_count: 307
summary: This document provides guidance on essential software components recommended for optimal Hyprland performance, explaining their purposes and startup methods.
tags:
    - hyprland
    - notification-daemon
    - pipewire
    - xdg-desktop-portal
    - authentication-agent
    - qt-wayland
    - fonts
category: guide
---

This page documents software that is **strongly** recommended to have running for a smooth Hyprland experience.

DEs like Plasma or GNOME will take care of this automatically. Hyprland will not, as you might want to use something else.

### A notification daemon[](#a-notification-daemon)

*Starting method:* Automatically, via D-Bus activation, when a notification is emitted. Alternatively, `exec-once` entry inside `hyprland.conf` can be used. The latter might be preferable, if there are several notification daemons installed on your system.

Many apps (e.g. Discord) may freeze without one running.

Examples: `dunst`, `mako`, `fnott` and `swaync`.

### Pipewire[](#pipewire)

*Starting method:* Automatic on systemd, manual otherwise.

Pipewire is not necessarily required, but screensharing will not work without it.

Install `pipewire` and `wireplumber` (**not** `pipewire-media-session`).

#### Non-systemd distros[](#non-systemd-distros)

Since there is no truly standardized way (outside of systemd) to load PipeWire when starting a graphical shell,[1](#fn:1) non-systemd distros like Gentoo or Artix provide a dedicated launcher.

It can be usually found by running `whereis <distro>-pipewire-launcher`. If such a file does not exist on your install, please refer to your distro’s documentation for help.

### XDG Desktop Portal[](#xdg-desktop-portal)

*Starting method:* Automatic on systemd, manual otherwise.

XDG Desktop Portal handles a lot of stuff for your desktop, like file pickers, screensharing, etc.

See the [Hyprland Desktop Portal Page.](https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland)

### Authentication Agent[](#authentication-agent)

*Starting method:* manual (`exec-once`)

Authentication agents are the things that pop up a window asking you for a password whenever an app wants to elevate its privileges.

See [hyprpolkitagent](https://wiki.hypr.land/Hypr-Ecosystem/hyprpolkitagent)

### Qt Wayland Support[](#qt-wayland-support)

*Starting method:* none (just a library)

Install `qt5-wayland` and `qt6-wayland`.

### Fonts[](#fonts)

*Starting method:* none (just a library)

A `sans-serif` font is required to render text. Without one, you may see squares instead of text. A common choice is `noto-fonts`.

For icons to display correctly, installing a Nerd Font or FontAwesome is recommended. Nerd Fonts will be used by default if available, then FontAwesome, before falling back to text.