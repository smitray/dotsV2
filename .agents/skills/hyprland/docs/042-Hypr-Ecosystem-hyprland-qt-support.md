---
title: hyprland-qt-support
url: https://wiki.hypr.land/Hypr-Ecosystem/hyprland-qt-support/
source: sitemap
fetched_at: 2026-02-01T09:23:07.608204208-03:00
rendered_js: false
word_count: 44
summary: This document explains how to configure Qt application styles for Hyprland using the hyprland-qt-support package, including available configuration variables and their settings.
tags:
    - hyprland
    - qt
    - qml
    - configuration
    - ui-elements
category: guide
---

[hyprland-qt-support](https://github.com/hyprwm/hyprland-qt-support) provides a QML style for hypr* qt6 apps.

## Configuration[](#configuration)

The config file is located in `~/.config/hypr/application-style.conf`.

VariableDescriptionTypeDefault`roundness`How much to round UI elements.int \[0 .. 3]`1``border_width`How wide the border should be around UI elements.int \[0 - 3]`1``reduce_motion`Reduce motion of elements (transitions, hover effects, etc).bool`false`