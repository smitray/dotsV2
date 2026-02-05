---
title: Hyprland on Other Distros
url: https://wiki.hypr.land/Nix/Hyprland-on-other-distros/
source: sitemap
fetched_at: 2026-02-01T09:22:32.62730629-03:00
rendered_js: false
word_count: 159
summary: This document explains how to install and use Hyprland on non-NixOS Linux distributions using Nix package management, including handling graphics drivers with nixGL.
tags:
    - hyprland
    - nix
    - linux
    - installation
    - nixgl
    - flakes
    - home-manager
category: guide
---

If you use Nix on distros other than NixOS, you can still use Hyprland.  
The best option for advanced users would be through [Home Manager](https://wiki.hypr.land/Nix/Hyprland-on-Home-Manager).

However, for most people, Home Manager is too complicated and not worth it outside NixOS. In those cases, Hyprland can be installed as a normal package.  
First, install nix with your system’s package manager (usually just called `nix`), then [enable flakes](https://nixos.wiki/wiki/Flakes#Enable_flakes), by adding this to `/etc/nix/nix.conf` or `~/.config/nix/nix.conf`:

once that is done, install Hyprland through `nix profile`:

Since you’re using Hyprland outside of NixOS, it won’t be able to find graphics drivers.  
To get around that, you can use [nixGL](https://github.com/guibou/nixGL).

Just install it like so:

`--impure` is needed due to `nixGL`’s reliance on hardware information.

Since 0.53.2, `start-hyprland` will automatically use `nixGL` if needed. For versions before that, you must use `nixGL start-hyprland`.

## Upgrading[](#upgrading)

In order to upgrade all your packages, you can run:

Check the [nix profile](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-profile.html) command documentation for other upgrade options.