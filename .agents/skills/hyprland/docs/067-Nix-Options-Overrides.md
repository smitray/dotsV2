---
title: Options & Overrides
url: https://wiki.hypr.land/Nix/Options-Overrides/
source: sitemap
fetched_at: 2026-02-01T09:22:37.291134341-03:00
rendered_js: false
word_count: 123
summary: This document explains how to override Hyprland package settings using Nix mechanisms like .override and .overrideAttrs, particularly focusing on NixOS and Home Manager configurations.
tags:
    - nix
    - hyprland
    - package-management
    - nixos
    - home-manager
    - override
category: guide
---

You can override the package through the `.override` or `.overrideAttrs` mechanisms.  
This is easily achievable on [NixOS](https://wiki.hypr.land/Nix/Hyprland-on-NixOS) or [Home Manager](https://wiki.hypr.land/Nix/Hyprland-on-Home-Manager).

## Package options[](#package-options)

These are the default options that the Hyprland package is built with.  
These can be changed by setting the appropriate option to `true` or `false`.

### Package[](#package)

### NixOS & HM modules[](#nixos--hm-modules)

## Options descriptions[](#options-descriptions)

### XWayland[](#xwayland)

XWayland is enabled by default in the Nix package.  
You can disable it either in the package itself, or through the module options.

## Using Nix repl[](#using-nix-repl)

If you’re using Nix (and not NixOS or Home Manager) and you want to override, you can do it like this:

Then you can run Hyprland from the built path.  
You can also use `overrideAttrs` to override `mkDerivation`’s arguments, such as `cmakeBuildType`: