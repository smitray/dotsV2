---
title: Status bars
url: https://wiki.hypr.land/Useful-Utilities/Status-Bars/
source: sitemap
fetched_at: 2026-02-01T09:22:19.429088441-03:00
rendered_js: false
word_count: 871
summary: This document provides guidance on configuring status bars and widget systems for Hyprland, covering popular options like Waybar, ashell, AGS/Astal, Eww, and Quickshell with installation and configuration details.
tags:
    - hyprland
    - status-bar
    - waybar
    - widget-system
    - configuration
    - desktop-environment
category: guide
---

## Simple status bars[](#simple-status-bars)

Typically you’ll be able to configure the order and style of widgets with little to no coding skill.

### Waybar[](#waybar)

Waybar is a GTK status bar made specifically for wlroots compositors and supports Hyprland by default. To use it, it’s recommended to use your distro’s package.

To start configuring, copy the configuration files from `/etc/xdg/waybar/` into `~/.config/waybar/`.

To use the workspaces module, replace all the occurrences of `sway/workspaces` with `hyprland/workspaces`. Additionally replace all occurrences of `sway/mode` with `hyprland/submap`

For more info regarding configuration, see [The Waybar Wiki](https://github.com/Alexays/Waybar/wiki/Module:-Hyprland).

#### How to launch[](#how-to-launch)

Type `waybar` into your terminal. In order to have Waybar launch alongside Hyprland, add this line to your Hyprland configuration:

Waybar also provides a systemd service. If you use Hyprland with [uwsm](https://wiki.hypr.land/Useful-Utilities/Systemd-start), you can enable it, using the following command.

#### Waybar FAQ[](#waybar-faq)

##### Active workspace doesn’t show up[](#active-workspace-doesnt-show-up)

Replace `#workspaces button.focused` with `#workspaces button.active` in `~/.config/waybar/style.css`.

##### Scrolling through workspaces[](#scrolling-through-workspaces)

Since a lot of configuration options from `sway/workspaces` are missing, you should deduce some of them by yourself. In the case of scrolling, it should look like this:

#### Window title is missing[](#window-title-is-missing)

The prefix for the window module that provides the title is `hyprland` not `wlr`. In your Waybar config, insert this module:

If you are using multiple monitors, you may want to insert the following option:

### ashell[](#ashell)

[ashell](https://malpenzibo.github.io/ashell/) is a ready to go Wayland status bar for Hyprland

- Ashell is ready to use out of the box. Just install it, start using it, and customize only what you need.
- Ashell comes with essential modules like workspaces, time, battery, network, and more. No need to hunt for plugins or write custom scripts.
- Powered by iced. A cross-platform GUI library for Rust
- Has a pretty limited configuration options. It’s a good and a bad thing at the same time. You can get a very decent result quickly and with a little effort, but some tricky waybar-alike tweaks are not possible.
- Calendar is absent but in the [roadmap](https://github.com/MalpenZibo/ashell/issues/181)

#### Workaround for calendar[](#workaround-for-calendar)

## Widget systems[](#widget-systems)

Use them when you want custom menus with fully customizable layout. You basically need to write code, but widget systems significantly ease the process. Below are three popular choices in alphabetical order.

[AGS/Astal](https://aylur.github.io/astal/)[EWW](https://elkowar.github.io/eww/)[Quickshell](https://quickshell.outfoxxed.me/)UI ToolkitGTK 3/4GTK 3QtConfig languageJS(X)/TS/languages that support [Gobject Introspection](https://en.wikipedia.org/wiki/List_of_language_bindings_for_GTK)Yuck (EWW’s flavor of Lisp)QML

### AGS/Astal[](#agsastal)

- [Astal](https://aylur.github.io/astal/) is a suite and framework to craft desktop shells and Wayland widgets with GTK.
- [AGS](https://aylur.github.io/ags/) (Aylur’s GTK Shell) is a scaffolding tool for Astal and TypeScript/Javascript(X). In simple words, it eases creation of Astal projects in those languages.

To get started with Astal, see its [installation instructions](https://aylur.github.io/astal/guide/installation) and [examples](https://aylur.github.io/astal/guide/introduction#supported-languages). For AGS, see its [Quick start](https://aylur.github.io/ags/guide/quick-start.html) page.

#### Advantages[](#advantages)

- Language flexibility: You can use your favorite if it supports [Gobject Introspection](https://en.wikipedia.org/wiki/List_of_language_bindings_for_GTK) (although JS(X)/TS are most well-supported by AGS)
- Provides a large set of libraries, including Network (both Wi-Fi and Ethernet) and Bluetooth

#### Disadvantages[](#disadvantages)

- Does not provide hot reload out of the box

### Eww[](#eww)

[Eww](https://github.com/elkowar/eww) (ElKowar’s Wacky Widgets) is a widget system made in Rust + GTK, which allows the creation of custom widgets similarly to AwesomeWM. The key difference is that it is independent of window manager/compositor.

Install Eww either using your distro’s package manager, by searching `eww-wayland`, or by manually compiling. In the latter case, you can follow the [instructions](https://elkowar.github.io/eww).

#### Advantages[](#advantages-1)

- Its Lisp-like config syntax is simple compared to other config languages
- Supports styling with SCSS out of the box

#### Disadvantages[](#disadvantages-1)

- Heavy reliance on external scripts/programs, as it does not provide many libraries
- Performance
  
  - Only supports GTK 3, which does not support GPU acceleration
  - Overhead from the use of external scripts and unnecessary component recreations on data re-evaluation

#### Configuration[](#configuration)

There are a few examples listed in the [Readme](https://github.com/elkowar/eww). It’s also highly recommended to read through the [Configuration options](https://elkowar.github.io/eww/configuration.html).

Here are some example widgets that might be useful for Hyprland:

Workspaces widget

This widget displays a list of workspaces 1-10. Each workspace can be clicked on to jump to it, and scrolling over the widget cycles through them. It supports different styles for the current workspace, occupied workspaces, and empty workspaces. It requires [bash](https://linux.die.net/man/1/bash), [awk](https://linux.die.net/man/1/awk), [stdbuf](https://linux.die.net/man/1/stdbuf), [grep](https://linux.die.net/man/1/grep), [seq](https://linux.die.net/man/1/seq), [socat](https://linux.die.net/man/1/socat), [jq](https://stedolan.github.io/jq/), and [Python 3](https://www.python.org/).

##### `~/.config/eww.yuck`[](#configewwyuck)

##### `~/.config/eww/scripts/change-active-workspace`[](#configewwscriptschange-active-workspace)

##### `~/.config/eww/scripts/get-active-workspace`[](#configewwscriptsget-active-workspace)

##### `~/.config/eww/scripts/get-workspaces`[](#configewwscriptsget-workspaces)

Active window title widget

This widget simply displays the title of the active window. It requires [awk](https://linux.die.net/man/1/awk), [stdbuf](https://linux.die.net/man/1/stdbuf), [socat](https://linux.die.net/man/1/socat), and [jq](https://stedolan.github.io/jq/).

##### `~/.config/eww/eww.yuck`[](#configewwewwyuck)

##### `~/.config/eww/scripts/get-window-title`[](#configewwscriptsget-window-title)

### Quickshell[](#quickshell)

[Quickshell](https://quickshell.outfoxxed.me/) is a flexible QtQuick-based desktop shell toolkit. Note that although Qt is notoriously hard to theme, Quickshell can be styled independently.

To get started, see the [setup instructions](https://quickshell.outfoxxed.me/docs/configuration/getting-started/) and a [guided hello world](https://quickshell.outfoxxed.me/docs/configuration/intro/)

#### Advantages[](#advantages-2)

- Provides advanced Wayland/Hyprland integrations, for example live window previews
- Automatically reloads config on changes out of the box

#### Disadvantages[](#disadvantages-2)

- Qt can be less intuitive to work with compared to GTK for its positioning system
- Does not yet provide a Wi-Fi service at the time of writing
- It is still in alpha and minor breaking changes are to be expected
- Styles are declared with components instead of in CSS, which might be less familiar for some people

## Tips[](#tips)

### Blur[](#blur)

Use the `blur` and `ignore_alpha` [layer rules](https://wiki.hypr.land/Configuring/Window-Rules/#layer-rules). The former enables blur, and the latter makes it ignore insufficiently opaque regions. Ideally, the value used with `ignore_alpha` is higher than the shadow opacity and lower than the bar/menu content’s opacity. Additionally, if it has transparent popups, you can use the `blur_popups` rule.