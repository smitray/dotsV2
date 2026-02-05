---
title: Using plugins
url: https://wiki.hypr.land/Plugins/Using-Plugins/
source: sitemap
fetched_at: 2026-02-01T09:22:10.967778564-03:00
rendered_js: false
word_count: 497
summary: This document provides instructions for using plugins in Hyprland, covering installation methods, safety considerations, and troubleshooting.
tags:
    - plugins
    - hyprland
    - installation
    - security
    - troubleshooting
    - configuration
category: guide
---

This page will tell you how to use plugins.

## Disclaimers[](#disclaimers)

Warning

Plugins are written in C++ and will run as a part of Hyprland.  
Make sure to *always* read the source code of the plugins you are going to use and to trust the source.  
Writing a plugin to wipe your computer is easy.

***Never*** trust random `.so` files you receive from other people.

## Getting plugins[](#getting-plugins)

Plugins come as *shared objects*, aka. `.so` files.

Hyprland does not have any “default” plugins, so any plugin you may want to use you will have to find yourself.

## Installing / Using plugins[](#installing--using-plugins)

It is *highly* recommended you use the Hyprland Plugin Manager, `hyprpm`. For manual instructions, see [here](#manual).

### hyprpm[](#hyprpm)

Note

If you are using [permission management](https://wiki.hypr.land/Configuring/Permissions), you should allow hyprpm to load plugins by adding this to your config:

otherwise you’ll get a popup asking for permission every time hyprpm tries to load a plugin.

Make sure you have the required dependencies: `cpio`, `cmake`, `git`, `meson` and `gcc`. You might also need `-dev` packages of Hyprland’s dependencies if your distro splits binaries and headers (e.g. Fedora or Debian).

Find a repository you want to install plugins from. As an example, we will use [hyprland-plugins](https://github.com/hyprwm/hyprland-plugins).

Once it finishes, you can list your installed plugins with:

Then, enable or disable them via `hyprpm enable name` and `hyprpm disable name`.

In order for the plugins to be loaded into Hyprland, run `hyprpm reload`.

You can add `exec-once = hyprpm reload` to your Hyprland config to have plugins loaded at startup. Optionally add `-n` flag to get notification that plugin loaded successfully (eye candy). Note regardless of whether `-n` is present or not, `reload` command will generate notification for warning and error events.

To update your plugins, run `hyprpm update`.

For all options of `hyprpm`, run `hyprpm -h`.

### Manual[](#manual)

Different plugins may have different build methods, refer to their instructions.

If you don’t have Hyprland headers installed, clone Hyprland, checkout to your version, build Hyprland, and run `sudo make installheaders`. Then build your plugin(s).

To load plugins manually, use `hyprctl plugin load path`.

You can unload plugins with `hyprctl plugin unload path`.

## FAQ About Plugins[](#faq-about-plugins)

### My Hyprland crashes\![](#my-hyprland-crashes)

Oh no. Oopsie. Usually means a plugin is broken. `hyprpm disable` it.

### How do I list my loaded plugins?[](#how-do-i-list-my-loaded-plugins)

`hyprctl plugin list`

### How do I make my own plugin?[](#how-do-i-make-my-own-plugin)

See [here](https://wiki.hypr.land/Plugins/Development/Getting-Started).

### Where do I find plugins?[](#where-do-i-find-plugins)

You can find our featured plugins at [hypr.land/plugins](https://hypr.land/plugins/). You can also see a list at [awesome-hyprland](https://github.com/hyprland-community/awesome-hyprland#plugins). Note that it may not be complete. Lastly, you can try searching around github for the `"hyprland plugin"` keyword.

### Are plugins safe?[](#are-plugins-safe)

As long as you read the source code of your plugin(s) and can see there’s nothing bad going on, they will be safe.

### Do plugins decrease Hyprland’s stability?[](#do-plugins-decrease-hyprlands-stability)

Hyprland employs a few tactics to unload plugins that crash. However, those tactics may not always work. In general, as long as the plugin is well-designed, it should not affect the stability of Hyprland.