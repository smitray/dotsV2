---
title: App clients
url: https://wiki.hypr.land/Useful-Utilities/App-Clients/
source: sitemap
fetched_at: 2026-02-01T09:22:42.685584569-03:00
rendered_js: false
word_count: 189
summary: This document provides alternatives to problematic desktop clients under Wayland, focusing on Discord and Matrix clients that offer better compatibility and performance.
tags:
    - wayland
    - discord
    - matrix
    - electron
    - gtk4
    - clients
    - replacement
category: guide
---

Some clients are known for being a massive pain under Wayland. Here are great replacements for them:

## Discord[](#discord)

- [WebCord](https://github.com/SpacingBat3/WebCord) is a Discord client based on the latest Electron, with support for the Wayland Ozone platform, as well as PipeWire screensharing. It has tons of great features and tries not to infringe on the Discord ToS.
- [Vesktop](https://github.com/Vencord/Vesktop) Like WebCord, Vesktop is a custom Discord client with improved performance and Wayland support. It also has built-in screen sharing, and in addition has support for plugins and custom themes. Vesktop even supports proper audio sharing when you screen share. Note that Vesktop relies on Vencord, a custom Discord client mod, which violates Discord’s terms of service. Use at your own risk.
- [dissent](https://github.com/diamondburned/dissent) is a Discord client written in GTK4. While it does infringe on Discord’s ToS, it’s relatively safe and doesn’t rely on any webview technologies.

## Matrix/Element[](#matrixelement)

[Fractal](https://wiki.gnome.org/Apps/Fractal) is a Matrix client written in GTK4. Much like Discord, Element is known to have a lot of problems as a result of being based on Electron. Fractal currently doesn’t support VoIP calling, but all other features are supported, including E2EE and cross-device verification.