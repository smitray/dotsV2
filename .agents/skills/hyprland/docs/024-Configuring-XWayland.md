---
title: XWayland
url: https://wiki.hypr.land/Configuring/XWayland/
source: sitemap
fetched_at: 2026-02-01T09:23:17.977884578-03:00
rendered_js: false
word_count: 190
summary: This document explains XWayland's role as a bridge between Xorg and Wayland, focusing on HiDPI display issues and Unix domain socket configurations.
tags:
    - xwayland
    - hidpi
    - wayland
    - xorg
    - unix-domain-sockets
    - display-scaling
category: reference
---

XWayland is the bridging mechanism between legacy Xorg programs and Wayland compositors.

## HiDPI XWayland[](#hidpi-xwayland)

XWayland currently looks pixelated on HiDPI screens, due to Xorg’s inability to scale.

This problem is mitigated by the [`xwayland:force_zero_scaling`](https://wiki.hypr.land/Configuring/Variables/#xwayland) option, which forces XWayland windows not to be scaled.

This will get rid of the pixelated look, but will not scale applications properly. To do this, each toolkit has its own mechanism.

The GDK\_SCALE variable won’t conflict with Wayland-native GTK programs.

Warning

XWayland HiDPI patches are no longer supported. Do not use them.

## Abstract Unix domain socket[](#abstract-unix-domain-socket)

X11 applications use Unix domain sockets to communicate with XWayland. On Linux, libX11 prefers to use the abstract Unix domain socket. This type of socket uses a separate, abstract namespace that is independent of the host filesystem. This makes abstract sockets more flexible but harder to [isolate](https://github.com/hyprwm/Hyprland/pull/8874) for some kinds of sandboxes like Flatpak. However, removing the abstract socket has [potential](https://gitlab.gnome.org/GNOME/mutter/-/issues/1613) security and compatibility issues.

Keeping that in mind, we add the [`xwayland:create_abstract_socket`](https://wiki.hypr.land/Configuring/Variables/#xwayland) option. When the abstract socket is disabled, only the regular Unix domain socket will be created.

** Abstract Unix domain sockets are available only on Linux-based systems*