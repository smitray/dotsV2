---
title: Hyprland on Home Manager
url: https://wiki.hypr.land/Nix/Hyprland-on-Home-Manager/
source: sitemap
fetched_at: 2026-02-01T09:22:15.194160147-03:00
rendered_js: false
word_count: 375
summary: This document provides guidance on configuring Hyprland using NixOS and Home Manager modules, covering installation, usage, plugins, and common troubleshooting issues.
tags:
    - hyprland
    - nixos
    - home-manager
    - window-manager
    - configuration
    - plugins
    - faq
    - systemd
category: guide
---

For a list of available options, check the [Home Manager options](https://nix-community.github.io/home-manager/options.xhtml#opt-wayland.windowManager.hyprland.enable).

Warning

**Required:**

- **NixOS Module:** enables critical components needed to run Hyprland properly.  
  Without this, you may have issues with missing session files in your Display Manager.

**Optional**:

- **Home Manager module:** lets you configure Hyprland declaratively through Home Manager.
- Configures Hyprland and adds it to your user’s `$PATH`, but does not make certain system-level changes such as adding a desktop session file for your display manager.  
  This is handled by the NixOS module, once you enable it.

## Installation[](#installation)

## Usage[](#usage)

Once the module is enabled, you can use it to declaratively configure Hyprland. Here is an example config:

## Plugins[](#plugins)

Hyprland plugins can be added through the `plugins` option:

For examples on how to build Hyprland plugins using Nix, see the [Nix/Plugins](https://wiki.hypr.land/Nix/Plugins) page.

## FAQ[](#faq)

### Fixing problems with themes[](#fixing-problems-with-themes)

If your themes for mouse cursors, icons or windows don’t load correctly, try setting them with `home.pointerCursor` and `gtk.theme`, which enable a bunch of compatibility options that should make the themes load in all situations.

Example configuration:

### Using the Home-Manager module with NixOS[](#using-the-home-manager-module-with-nixos)

If you want to use the Home Manager module while using the Hyprland package you’ve defined in your NixOS module, you can now do so as long as you’re running [Home Manager `5dc1c2e40410f7dabef3ba8bf4fdb3145eae3ceb`](https://github.com/nix-community/home-manager/commit/5dc1c2e40410f7dabef3ba8bf4fdb3145eae3ceb) or later by setting your `package` and `portalPackage` to `null`.

Make sure **not** to mix versions of Hyprland and XDPH. If your NixOS config uses Hyprland from the flake, you should also use XDPH from the flake. If you set the Home Manager Hyprland module package to `null`, you should also set the XDPH package to `null`.

### Programs don’t work in systemd services, but do on the terminal[](#programs-dont-work-in-systemd-services-but-do-on-the-terminal)

This problem is related to systemd not importing the environment by default. It will not have knowledge of `PATH`, so it cannot run the commands in the services. This is the most common with user-configured services such as `hypridle` or `swayidle`.

To fix it, add to your config:

This setting will produce the following entry in the Hyprland config:

Make sure to use the above command if you do not use the Home Manager module.

#### NixOS UWSM[](#nixos-uwsm)

If you’re using the NixOS module with UWSM (`programs.hyprland.withUWSM = true`), you can [set environment variables](https://github.com/Vladimir-csp/uwsm?tab=readme-ov-file#4-environments-and-shell-profile "Environments and shell profile - UWSM") like this: