---
title: Getting started
url: https://wiki.hypr.land/Plugins/Development/Getting-Started/
source: sitemap
fetched_at: 2026-02-01T09:22:03.189977027-03:00
rendered_js: false
word_count: 597
summary: This document provides a comprehensive guide on creating Hyprland plugins from scratch, covering the fundamentals of plugin architecture, development setup, and essential functions needed for plugin initialization and loading.
tags:
    - hyprland
    - plugin-development
    - cplusplus
    - dynamic-modules
    - api-reference
    - tutorial
category: guide
---

This page documents the basics of making your own Hyprland plugin from scratch.

## How do plugins work?[](#how-do-plugins-work)

Plugins are basically dynamic objects loaded by Hyprland. They have (almost) full access to every part of Hyprland’s internal process, and as such, can modify and change way more than a script.

## Prerequisites[](#prerequisites)

In order to write a Hyprland plugin, you will need:

- Knowledge of C++
- The ability to read
- A rough understanding of the Hyprland internals (you *can* learn this alongside your development work)

## Making your first plugin[](#making-your-first-plugin)

Open your favorite code editor.

Make a new directory, in this example we will use `MyPlugin`.

***→ If you have the Hyprland headers***

If you install with `make install`, you should have the headers. In that case, no further action is required.

***→ If you don’t have the Hyprland source cloned***

Clone the Hyprland source code to a subdirectory, in our example `MyPlugin/Hyprland`. Run `cd Hyprland && make debug && sudo make installheaders && cd ..`.

Now that you have the Hyprland sources set up, you can either start from scratch if you know how, or take a look at some simple plugins in the [official plugins repo](https://github.com/hyprwm/hyprland-plugins) like for example `csgo-vulkan-fix` or `hyprwinwrap`.

### The basic parts of the plugin[](#the-basic-parts-of-the-plugin)

Starting from the top, you will have to include the plugin API:

Feel free to take a look at the header. It contains a bunch of useful comments.

We also create a global pointer for our handle:

We will initialize it in our plugin init function later. It serves as an internal “ID” of our plugin.

Then, there is the API version method:

This method will tell Hyprland what API version was used to compile this plugin. Do NOT change it. It will be set to the correct value when compiling.

Skipping over some example handlers, we have two important functions:

The first method will be called when your plugin gets initialized (loaded).

You can, and probably should, initialize everything you may want to use in there.

It’s worth noting that adding config variables is *only* allowed in this function.

The plugin init function is *required*.

The return value should be the `PLUGIN_DESCRIPTION_INFO` struct which lets Hyprland know about your plugin’s name, description, author and version.

Make sure to store your `HANDLE` as it’s going to be required for API calls.

The second method is not required, and will be called when your plugin is being unloaded by the user.

If your plugin is being unloaded because it committed a fault, this function will *not* be called.

You do not have to unload layouts, remove config options, remove dispatchers, window decorations or unregister hooks in the exit method. Hyprland will do that for you.

### Setting up a development environment[](#setting-up-a-development-environment)

In order to make your life easier, it’s a good idea to work on a nested debug Hyprland session. Unless you need to test some things that require real hardware (e.g. trackpad gestures), you definitely should use a nest.

See [the Contributing Section](https://wiki.hypr.land/Contributing-and-Debugging/#development-environment) for instructions on setting up a development environment.

### Loading / reloading plugins[](#loading--reloading-plugins)

Build your plugin, and you can load it in your nest with

and unload with

The normal development cycle would usually mean loading the plugin, checking your changes, building the plugin with new changes, unload + load, and repeat.

You can have a one-liner like so:

as a “reload” of the plugin.

### More advanced stuff[](#more-advanced-stuff)

Take a look at the `src/plugins/PluginAPI.hpp` header. It has comments to every method to let you know what it is.

For more explanation on a few concepts, see [Advanced](https://wiki.hypr.land/Plugins/Development/Advanced) and [Plugin Guidelines](https://wiki.hypr.land/Plugins/Development/Plugin-Guidelines)