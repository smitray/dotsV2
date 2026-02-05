---
title: Hyprland on NixOS
url: https://wiki.hypr.land/Nix/Hyprland-on-NixOS/
source: sitemap
fetched_at: 2026-02-01T09:22:03.199974235-03:00
rendered_js: false
word_count: 185
summary: This document explains how to configure Hyprland on NixOS using the provided NixOS module and optional Home Manager module, covering necessary system components and troubleshooting common issues.
tags:
    - nixos
    - hyprland
    - desktop-environment
    - configuration
    - wayland
    - module
    - home-manager
    - graphics-drivers
category: guide
---

The NixOS module enables critical components needed to run Hyprland properly, such as polkit, [xdg-desktop-portal-hyprland](https://github.com/hyprwm/xdg-desktop-portal-hyprland), graphics drivers, fonts, dconf, xwayland, and adding a proper Desktop Entry to your Display Manager.

Make sure to check out the options of the [NixOS module](https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=hyprland).

Warning

**Required:**

- **NixOS Module:** enables critical components needed to run Hyprland properly.  
  Without this, you may have issues with missing session files in your Display Manager.

**Optional**:

- **Home Manager module:** lets you configure Hyprland declaratively through Home Manager.
- Configures Hyprland and adds it to your user’s `$PATH`, but does not make certain system-level changes such as adding a desktop session file for your display manager.  
  This is handled by the NixOS module, once you enable it.

## Fixing problems with themes[](#fixing-problems-with-themes)

If your themes for your mouse cursors, icons or windows don’t load correctly, see the relevant section in [Hyprland on Home Manager](https://wiki.hypr.land/Nix/Hyprland-on-Home-Manager).

If you prefer not to use Home Manager, you can also resolve the issues with GTK themes using dconf like so:

## Upstream module[](#upstream-module)

The [upstream module](https://github.com/hyprwm/Hyprland/blob/main/nix/module.nix) provides options similar to the ones in the [Home Manager module](https://wiki.hypr.land/Nix/Hyprland-on-Home-Manager).

To use it, simply add