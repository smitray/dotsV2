---
title: Plugins
url: https://wiki.hypr.land/Nix/Plugins/
source: sitemap
fetched_at: 2026-02-01T09:22:40.834273852-03:00
rendered_js: false
word_count: 203
summary: This document explains how to manage Hyprland plugins on Nix systems, covering the differences from other distributions and detailing methods for using plugins from Nixpkgs, official hyprland-plugins, and building custom plugins with Nix.
tags:
    - hyprland
    - nix
    - plugins
    - package-management
    - flake
    - build-system
category: guide
---

Hyprland plugins are managed differently on Nix than on other distros.  
The most notable change is that `hyprpm` is unsupported, but we have our own way of building and managing plugins.

## Using plugins from Nixpkgs[](#using-plugins-from-nixpkgs)

In Nixpkgs, there are Hyprland plugins packaged for the Hyprland version in Nixpkgs. You can use them like this:

You can find which plugins are included using `nix search nixpkgs#hyprlandPlugins ^`.

## hyprland-plugins[](#hyprland-plugins)

Official plugins made/maintained by vaxry.

To use these plugins, it is recommended to be already using the Hyprland flake, and **not** the Nixpkgs version.

First, add the flake to your flake inputs:

The `inputs.hyprland.follows` line makes hyprland-plugins use the exact Hyprland revision you have locked.  
This means there aren’t any version mismatches, as long as you update both inputs at once.

The next step is adding the plugins to Hyprland:

## Building plugins with Nix[](#building-plugins-with-nix)

The plugins inside Nixpkgs, as well as the ones in `hyprland-plugins`, are built using a general function: `mkHyprlandPlugin`.  
Any plugin can be made to work with it. The general usage is presented below, exemplified through hy3’s derivation:

In a similar manner to `stdenv.mkDerivation`, `mkHyprlandPlugin` takes an attrset with mostly the same options as `mkDerivation`, as it is essentially a wrapper around it.