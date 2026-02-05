---
title: Hyprland Wiki
url: https://wiki.hypr.land/
source: sitemap
fetched_at: 2026-02-01T09:23:32.15035732-03:00
rendered_js: false
word_count: 175
summary: This document serves as an introduction to the Hyprland Wiki, providing essential information about Hyprland as a Wayland compositor and directing users to resources for troubleshooting and configuration.
tags:
    - wayland
    - compositor
    - hyprland
    - wiki
    - faq
    - troubleshooting
category: guide
---

Hello there, dear traveler! Welcome to the Hyprland Wiki!

Take a tour of the pages on the left and read ones that you may need.

***This wiki is versioned!*** By default, you are reading the wiki for *the latest Hyprland git commit*. Click on the version selector and select your version if you are running a tagged release (which you very likely are, you can check with `hyprctl version`).

## Wayland info (especially useful for Xorg users)[](#wayland-info-especially-useful-for-xorg-users)

A Wayland compositor is a fully autonomous Display Server, like Xorg itself. It is **not** possible to mix’n’match Wayland compositors like you could on Xorg with window managers and compositors. It is also not entirely possible, nor recommended, to try and use all Xorg applications on Wayland. See [this page](https://wiki.hypr.land/Useful-Utilities/) for a list of recommended Wayland native/compatible programs.

Wayland **compositors** should not be confused with Xorg **window managers**.

## IMPORTANT[](#important)

If you are having issues, please try [reading the FAQ](https://wiki.hypr.land/FAQ) and configuring sections — chances are your issue is described somewhere there. If not, you can try [searching the issues](https://github.com/hyprwm/Hyprland/issues).