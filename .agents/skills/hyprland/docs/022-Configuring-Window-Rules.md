---
title: Window Rules
url: https://wiki.hypr.land/Configuring/Window-Rules/
source: sitemap
fetched_at: 2026-02-01T09:22:46.632780303-03:00
rendered_js: false
word_count: 1969
summary: This document explains how to configure window rules in Hyprland to control window behavior based on their properties, including syntax, props, effects, and regex usage.
tags:
    - window-rules
    - hyprland
    - configuration
    - regex
    - window-management
    - props
    - effects
category: reference
---

Warning

Rules are evaluated top to bottom, so the order they’re written in does matter! More info in [Notes](#notes)

## Window Rules[](#window-rules)

You can set window rules to achieve different window behaviors based on their properties.

### Syntax[](#syntax)

Basic named rule syntax:

Basic anonymous rule syntax:

Rules are split into two categories of parameters: *props* and *effects*. Props are the `match:` parts, which are used to determine if a window should get the rule. Effects are what is applied.

*All* props must match for a rule to be applied.

You can have as many props and effects per rule as you please, in any order as you please, as long as:

- there is only one of one type (e.g. specifying `match:class` twice is invalid)
- there is at least one *prop*

### Props[](#props)

The supported fields for props are:

FieldArgumentDescriptionmatch:class\[RegEx]Windows with `class` matching `RegEx`.match:title\[RegEx]Windows with `title` matching `RegEx`.match:initial\_class\[RegEx]Windows with `initialClass` matching `RegEx`.match:initial\_title\[RegEx]Windows with `initialTitle` matching `RegEx`.match:tag\[name]Windows with matching `tag`.match:xwayland\[bool]Xwayland windows.match:float\[bool]Floating windows.match:fullscreen\[bool]Fullscreen windows.match:pin\[bool]Pinned windows.match:focus\[bool]Currently focused window.match:group\[bool]Grouped windows.match:modal\[bool]Modal windows (e.g. “Are you sure” popups)match:fullscreen\_state\_client\[client]Windows with matching `fullscreenstate`. `client` can be `0` - none, `1` - maximize, `2` - fullscreen, `3` - maximize and fullscreen.match:fullscreen\_state\_internal\[internal]Windows with matching `fullscreenstate`. `internal` can be `0` - none, `1` - maximize, `2` - fullscreen, `3` - maximize and fullscreen.match:workspace\[workspace]Windows on matching workspace. `w` can be `id`, `name:string` or `workspace selector`.match:content\[int]Windows with specified content type (none = 0, photo = 1, video = 2, game = 3)match:xdg\_tag\[RegEx]Match a window by its xdgTag (see `hyprctl clients` to check if it has one)

Keep in mind that you *have* to declare at least one field, but not all.

Note

To get more information about a window’s class, title, XWayland status or its size, you can use `hyprctl clients`.

Note

In the output of the `hyprctl clients` command: `fullscreen` refers to `fullscreen_state_internal` and `fullscreenClient` refers to `fullscreen_state_client`

### RegEx writing[](#regex-writing)

Please note Hyprland uses [Google’s RE2](https://github.com/google/re2) for parsing RegEx. This means that all operations requiring polynomial time to compute will not work. See the [RE2 wiki](https://github.com/google/re2/wiki/Syntax) for supported extensions.

If you want to *negate* a RegEx, as in pass only when the RegEx *fails*, you can prefix it with `negative:`, e.g.: `negative:kitty`.

## Effects[](#effects)

### Static effects[](#static-effects)

Static effects are evaluated once when the window is opened and never again. This essentially means that it is always the `initialTitle` and `initialClass` which will be found when matching on `title` and `class`, respectively.

Warning

It is not possible to `float` (or any other static rule) a window based on a change in the `title` after the window has been created. This applies to all static effects listed here.

EffectargumentDescriptionfloat\[on]Floats a window.tile\[on]Tiles a window.fullscreen\[on]Fullscreens a window.maximize\[on]Maximizes a window.fullscreen\_state\[internal] \[client]Sets the focused window’s fullscreen mode and the one sent to the client, where internal and client can be `0` - none, `1` - maximize, `2` - fullscreen, `3` - maximize and fullscreen.move\[expr] \[expr]Moves a floating window to a given coordinate, monitor-local. Two expressions are space-separated.size\[expr] \[expr]Resizes a floating window to a given size. Two expressions are space-separated.center\[on]If the window is floating, will center it on the monitor.pseudo\[on]Pseudotiles a window.monitor\[id]Sets the monitor on which a window should open. `id` can be either the id number or the name (e.g. `1` or `DP-1`).workspace\[w]Sets the workspace on which a window should open (for workspace syntax, see [dispatchers-&gt;workspaces](https://wiki.hypr.land/Configuring/Dispatchers#workspaces)).  
You can also set \[w] to `unset`. This will unset all previous workspace rules applied to this window. Additionally you can add `silent` after the workspace to make the window open silently.no\_initial\_focus\[on]Disables the initial focus to the windowpin\[on]Pins the window (i.e. show it on all workspaces). *Note: floating only*.group\[options]Sets window group properties. See the note below.suppress\_event\[types…]Ignores specific events from the window. Events are space separated, and can be: `fullscreen`, `maximize`, `activate`, `activatefocus`, `fullscreenoutput`.content\[none|photo|video|game]Sets content type.no\_close\_for\[ms]Makes the window uncloseable with the `killactive` dispatcher for a given amount of ms on open.

#### Expressions[](#expressions)

Expressions are space-separated, so your math cannot have spaces. They are regular, math expressions, with a few variables exposed, names of which are self-explanatory. All position variables are monitor-local.

- `monitor_w` and `monitor_h` for monitor size
- `window_x` and `window_y` for window position
- `window_w` and `window_h` for window size
- `cursor_x` and `cursor_y` for cursor position

Example expressions:

- `window_w*0.5`
- `(monitor_w/2)+17`

It’s probably a good idea to surround your expressions with parentheses for clarity, with space-separation:

- `(monitor_w*0.5) (monitor_h*0.5)`
- `((monitor_w*0.5)+17) (monitor_h*0.2)`

### Dynamic effects[](#dynamic-effects)

Dynamic effects are re-evaluated every time a property changes.

EffectargumentDescriptionpersistent\_size\[on]For floating windows, internally store their size. When a new floating window opens with the same class and title, restore the saved size.no\_max\_size\[on]Removes max size limitations. Especially useful with windows that report invalid max sizes (e.g. winecfg).stay\_focused\[on]Forces focus on the window as long as it’s visible.animation\[style] (\[opt])Forces an animation onto a window, with a selected opt. Opt is optional.border\_color\[c]Force the border color of the window.  
Options for c: `color`/`color ... color angle` -&gt; sets the active border color/gradient OR `color color`/`color ... color angle color ... color [angle]` -&gt; sets the active and inactive border color/gradient of the window. See [variables-&gt;colors](https://wiki.hypr.land/Configuring/Variables#variable-types) for color definition.idle\_inhibit\[mode]Sets an idle inhibit rule for the window. If active, apps like `hypridle` will not fire. Modes: `none`, `always`, `focus`, `fullscreen`.opacity\[a]Additional opacity multiplier. Options for a: `float` -&gt; sets an overall opacity, `float float` -&gt; sets active\_opacity and inactive\_opacity respectively, `float float float` -&gt; sets active\_opacity, inactive\_opacity and fullscreen\_opacity respectively.tag\[name]Applies the tag `name` to the window, use prefix `+`/`-` to set/unset flag, or no prefix to toggle the flag.max\_size\[w] \[h]Sets the maximum size (x,y -&gt; int). Applies to floating windows. (use `misc:size_limits_tiled` to include tiled windows.)min\_size\[w] \[h]Sets the minimum size (x,y -&gt; int). Applies to floating windows. (use `misc:size_limits_tiled` to include tiled windows.)border\_size\[int]Sets the border size.rounding\[int]Forces the application to have X pixels of rounding, ignoring the set default (in `decoration:rounding`). Has to be an int.rounding\_power\[float]Overrides the rounding power for the window (see `decoration:rounding_power`).allows\_input\[on]Forces an XWayland window to receive input, even if it requests not to do so. (Might fix issues like Game Launchers not receiving focus for some reason)dim\_around\[on]Dims everything around the window. Please note that this rule is meant for floating windows and using it on tiled ones may result in strange behavior.decorate\[on](default is *true*) Whether to draw window decorations or notfocus\_on\_activate\[on]Whether Hyprland should focus an app that requests to be focused (an `activate` request).keep\_aspect\_ratio\[on]Forces aspect ratio when resizing window with the mouse.nearest\_neighbor\[on]Forces the window to use [nearest neighbor](https://en.wikipedia.org/wiki/Image_scaling#Nearest-neighbor_interpolation) filtering.no\_anim\[on]Disables the animations for the window.no\_blur\[on]Disables blur for the window.no\_dim\[on]Disables window dimming for the window.no\_focus\[on]Disables focus to the window.no\_follow\_mouse\[on]Prevents the window from being focused when the mouse moves over it when `input:follow_mouse=1` is set.no\_shadow\[on]Disables shadows for the window.no\_shortcuts\_inhibit\[on]Disallows the app from [inhibiting your shortcuts](https://wayland.app/protocols/keyboard-shortcuts-inhibit-unstable-v1).no\_screen\_share\[on]Hides the window and its popups from screen sharing by drawing black rectangles in their place. The rectangles are drawn even if other windows are above.no\_vrr\[on]Disables VRR for the window. Only works when [`misc:vrr`](https://wiki.hypr.land/Configuring/Variables/#Misc) is set to `2` or `3`.opaque\[on]Forces the window to be opaque.force\_rgbx\[on]Forces Hyprland to ignore the alpha channel on the whole window’s surfaces, effectively making it *actually, fully 100% opaque*.sync\_fullscreen\[on]Whether the fullscreen mode should always be the same as the one sent to the window (will only take effect on the next fullscreen mode change).immediate\[on]Forces the window to allow tearing. See [the Tearing page](https://wiki.hypr.land/Configuring/Tearing).xray\[on]Sets blur xray mode for the window.render\_unfocused\[on]Forces the window to think it’s being rendered when it’s not visible. See also [Variables - Misc](https://wiki.hypr.land/Configuring/Variables/#Misc) for setting `render_unfocused_fps`.scroll\_mouse\[float]Forces the window to override the variable `input:scroll_factor`.scroll\_touchpad\[float]Forces the window to override the variable `input:touchpad:scroll_factor`.

All dynamic effects can be set with `setprop`, see [`setprop`](https://wiki.hypr.land/Configuring/Dispatchers#setprop).

### `group` window rule options[](#group-window-rule-options)

- `set` \[`always`] - Open window as a group.
- `new` - Shorthand for `barred set`.
- `lock` \[`always`] - Lock the group that added this window. Use with `set` or `new` (e.g. `new lock`) to create a new locked group.
- `barred` - Do not automatically group the window into the focused unlocked group.
- `deny` - Do not allow the window to be toggled as or added to group (see `denywindowfromgroup` dispatcher).
- `invade` - Force open window in the locked group.
- `override` \[other options] - Override other `group` rules, e.g. You can make all windows in a particular workspace open as a group, and use `group override barred` to make windows with specific titles open as normal windows.
- `unset` - Clear all `group` rules.

Note

The `group` rule without options is a shorthand for `group set`.

By default, `set` and `lock` only affect new windows once. The `always` qualifier makes them always effective.

### Tags[](#tags)

Window may have several tags, either static or dynamic. Dynamic tags will have a suffix of `*`. You may check window tags with `hyprctl clients`.

Use the `tagwindow` dispatcher to add a static tag to a window:

Use the `tag` rule to add a dynamic tag to a window:

Or with a keybind for convenience:

The `tag` rule can only manipulate dynamic tags, and the `tagwindow` dispatcher only works with static tags (i.e. once the dispatcher is called, dynamic tags will be cleared).

### Example Rules[](#example-rules)

### Notes[](#notes)

Effects that are marked as *Dynamic* will be reevaluated if the matching property of the window changes.  
For instance, if a rule is defined that changes the `border_color` of a window when it is floating, then the `border_color` will change to the requested color when it is set to floating, and revert to the default color when it is tiled again.

Effects will be processed from top to bottom, where the *last* match will take precedence. i.e.

Here, all non-fullscreen kitty windows will have `opacity 0.8`, except if they are floating. Otherwise, they will have `opacity 0.5`. The rest of the non-fullscreen floating windows will have `opacity 0.5`.

Here, all kitty windows will have `opacity 0.8`, even if they are floating. The rest of the floating windows will have `opacity 0.5`.

Important

Named rules take precedence over anonymous ones. That is, rules are evaluated top to bottom, but all named rules get evaluated first, then all anonymous ones.

Note

Opacity is a PRODUCT of all opacities by default. For example, setting `active_opacity` to `0.5` and `opacity` to `0.5` will result in a total opacity of `0.25`.  
You are allowed to set opacities over `1.0`, but any opacity product over `1.0` will cause graphical glitches.  
For example, using `0.5 * 2 = 1` is fine, but `0.5 * 4 = 2` will cause graphical glitches.  
You can put `override` after an opacity value to override it to an exact value rather than a multiplier. For example, to set active and inactive opacity to 0.8, and make fullscreen windows fully opaque regardless of other opacity rules:

### Dynamically enabling / disabling / changing rules[](#dynamically-enabling--disabling--changing-rules)

Only named rules can be dynamically changed, enabled or disabled. Anonymous rules cannot be.

For enabling or disabling, the keyword `enable` is exposed:

For changing properties, the same syntax can be used:

*the singlequotes are necessary, otherwise your shell might try to parse the string*

## Layer Rules[](#layer-rules)

Some things in Wayland are not windows, but layers. That includes, for example: app launchers, status bars, or wallpapers.

Those have specific rules, separate from windows. Their syntax is the exact same, but they have different props and effects.

### Props[](#props-1)

FieldArgumentDescriptionmatch:namespace\[RegEx]namespace of the layer, check `hyprctl layers`.

### Effects[](#effects-1)

effectargumentdescriptionno\_anim\[on]Disables animations.blur\[on]Enables blur for the layer.blur\_popups\[on]Enables blur for the popups.ignore\_alpha\[a]Makes blur ignore pixels with opacity of `a` or lower. `a` is float value from `0` to `1`. `a = 0` if unspecified.dim\_around\[on]Dims everything behind the layer.xray\[on]Sets the blur xray mode for a layer. `0` for off, `1` for on, `unset` for default.animation\[style]Allows you to set a specific animation style for this layer.order\[n]Sets the order relative to other layers. A higher `n` means closer to the edge of the monitor. Can be negative. `n = 0` if unspecified.above\_lock\[0/1/2]If non-zero, renders the layer above the lockscreen when the session is locked. If set to `2`, you can interact with the layer on the lockscreen, otherwise it will only be rendered above it.no\_screen\_share\[on]Hides the layer from screen sharing by drawing a black rectangle over it.

### Examples[](#examples)