---
title: aquamarine
url: https://wiki.hypr.land/Hypr-Ecosystem/aquamarine/
source: sitemap
fetched_at: 2026-02-01T09:23:30.145808052-03:00
rendered_js: false
word_count: 98
summary: This document provides documentation for aquamarine, a lightweight Linux rendering backend library that implements low-level KMS/DRM rendering backends rather than serving as a full compositor library replacement.
tags:
    - linux
    - rendering
    - drm
    - kms
    - wayland
    - compositor
    - backend
category: reference
---

[aquamarine](https://github.com/hyprwm/aquamarine) is a very light linux rendering backend library.

It is not a replacement or competitor to any other wayland compositor library (e.g. wlroots, libweston), instead implementing only the low-level KMS/DRM/etc rendering backends.

## Configuration[](#configuration)

Configuration options are passed via environment variables starting with `AQ_` to an app that uses aquamarine, e.g. Hyprland.

### Variables[](#variables)

NameDescription`AQ_TRACE`Enables trace (very, very verbose) logging.`AQ_DRM_DEVICES`A colon-separated list of DRM devices (aka. GPUs) to use.  
The first will be used as primary.  
Example: `/dev/dri/card1:/dev/dri/card0`.`AQ_NO_MODIFIERS`Disables modifiers for DRM buffers.`AQ_MGPU_NO_EXPLICIT`Disables passing of explicit fences for multi-gpu scanouts`AQ_NO_ATOMIC`**(HEAVILY NOT RECOMMENDED)** Disable atomic modesetting.

## Documentation[](#documentation)

Documentation will come soon.