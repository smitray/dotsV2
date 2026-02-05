---
title: xdg-desktop-portal-hyprland
url: https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/
source: sitemap
fetched_at: 2026-02-01T09:22:46.802060374-03:00
rendered_js: false
word_count: 369
summary: This document explains how to configure and use xdg-desktop-portal-hyprland, a desktop portal implementation for Hyprland that enables features like screensharing and global shortcuts.
tags:
    - xdg-desktop-portal
    - hyprland
    - screensharing
    - wayland
    - compositor
    - configuration
    - kde
    - file-picker
category: guide
---

An XDG Desktop Portal is a program that lets other applications communicate with the compositor through D-Bus.

A portal implements certain functionalities, such as opening file pickers or screen sharing.

[xdg-desktop-portal-hyprland](https://github.com/hyprwm/xdg-desktop-portal-hyprland) is Hyprland’s xdg-desktop-portal implementation. It allows for screensharing, global shortcuts, etc.

Note

Throughout this document, `xdg-desktop-portal-hyprland` will be referred to as XDPH.

Warning

XDPH doesn’t implement a file picker. For that, it is recommended to install `xdg-desktop-portal-gtk` alongside XDPH.

## Installing[](#installing)

## Usage[](#usage)

XDPH is automatically started by D-Bus, once Hyprland starts.

To check if everything is OK is, try to screenshare anything, or opening OBS and select the PipeWire source.  
If XDPH is running, a Qt menu will pop up asking you what to share.

XDPH will work on other wlroots compositors, but features available only on Hyprland will not work (e.g. window sharing).

For a nuclear option, you can use this script and `exec-once` it:

Adjust the paths if they’re incorrect.

## Share Picker Doesn’t Use the System Theme[](#share-picker-doesnt-use-the-system-theme)

Try one or both:

If it works, add it to your config in `exec-once`.

## Using the KDE File Picker With XDPH[](#using-the-kde-file-picker-with-xdph)

XDPH does not implement a file picker and uses the GTK one as a fallback by default (see `/usr/share/xdg-desktop-portal/hyprland-portals.conf`). If you want to use the KDE file picker but let XDPH handle everything else, create a file `~/.config/xdg-desktop-portal/hyprland-portals.conf` with the following content:

You can read more about this in the [xdg-desktop-portal documentation in the Arch Wiki](https://wiki.archlinux.org/title/XDG_Desktop_Portal). Note that some applications like Firefox may require additional configuration to use the KDE file picker.

## Debugging[](#debugging)

If you get long app launch times, or screensharing does not work, consult the logs.

`systemctl --user status xdg-desktop-portal-hyprland`

If you see a crash, it’s likely you are missing either `qt6-wayland` or `qt5-wayland`.

If the portal does not autostart, does not function when manually started, and does not produce any error logs, it’s very likely your [XDG env variables](https://wiki.hypr.land/Configuring/Environment-variables/#xdg-specifications) are messed up

## Configuration[](#configuration)

Example:

Config file `~/.config/hypr/xdph.conf` allows for these variables:

### category screencopy[](#category-screencopy)

VariableDescriptionTypeDefault`max_fps`Maximum fps of a screensharing session.  
`0` means no limit.int`120``allow_token_by_default`If enabled, will tick the “Allow restore token” box by default.bool`false``custom_picker_binary`If non-empty, will use that **binary** as your share picker.  
Please note that it has to conform to the stdout selection layout of `hyprland-share-picker`.string`"hyprland-share-picker"`