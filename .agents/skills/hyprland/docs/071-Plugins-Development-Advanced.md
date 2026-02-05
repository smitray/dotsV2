---
title: Advanced
url: https://wiki.hypr.land/Plugins/Development/Advanced/
source: sitemap
fetched_at: 2026-02-01T09:22:28.972754696-03:00
rendered_js: false
word_count: 433
summary: This document provides advanced guidance on working with the Hyprland Plugin API, covering topics such as accessing private members, using function hooks, and managing plugin configuration.
tags:
    - hyprland
    - plugin-api
    - function-hooks
    - configuration
    - private-members
    - api-reference
category: reference
---

This page documents a few advanced things about the Hyprland Plugin API.

## Accessing private members[](#accessing-private-members)

If you need access to a private member of a Hyprland class, you can surround includes with a macro which will change the visibility to public. Note that some Hyprland files include the STL which may end up breaking if you attempt this. If you encounter this issue, make sure to include the offending STL import before the section where you include the Hyprland file.

## Using Function Hooks[](#using-function-hooks)

Warning

Function hooks are only available on `AMD64` (`x86_64`). Attempting to hook on any other arch will make Hyprland simply ignore your hooking attempt.

Function hooks are intimidating at first, but when used properly can be *extremely* powerful.

Function hooks allow you to intercept any call to the function you hook.

Let’s look at a simple example:

This will be the function we want to hook. `Events::` is a namespace, not a class, so this is just a plain function.

We have just made a hook. Now, whenever Hyprland calls `Events::listener_monitorFrame`, our hook will be called instead!

This way, you can run code before / after the function, modify the inputs or results, or even block the function from executing.

`CFunctionHook` can also be unhooked whenever you please. Just run `unhook()`. It can be rehooked later by calling `hook()` again.

### Member functions[](#member-functions)

For members, e.g. `CCompositor::focusWindow(CWindow*, wlr_surface*)` you will also need to add the thisptr argument to your hook:

Warning

Please note method lookups are slow and should not be used often. The entries *will not* change during runtime, so it’s a good idea to make the lookups `static`.

### Why use findFunctionsByName?[](#why-use-findfunctionsbyname)

Why use that instead of e.g. `&CCompositor::focusWindow`? Two reasons:

1. Less breakage. Whenever someone updates Hyprland, that address might become invalid. findFunctionsByName is more resilient. As long as the function exists, it will be found.
2. Error handling. The method array contains, besides the address, the signatures. You can verify those to make 100% sure you got the right function, or throw an error if it was not found.

## Using the config[](#using-the-config)

You can register config values in the `PLUGIN_INIT` function:

Plugin variables ***must*** be in the `plugins:` category. Further categories are up to you. It’s generally a good idea to group all variables from your plugin in a subcategory with the plugin name, e.g. `plugins:myPlugin:variable1`.

For retrieving the values, call `HyprlandAPI::getConfigValue`.

Please remember that the pointer to your config value will never change after `PLUGIN_INIT`, so to greatly optimize performance, make it static:

## Further[](#further)

Read the API at `src/plugins/PluginAPI.hpp`, check out the [official plugins](https://github.com/hyprwm/hyprland-plugins).

And, most importantly, have fun!