---
title: Workspace Rules
url: https://wiki.hypr.land/Configuring/Workspace-Rules/
source: sitemap
fetched_at: 2026-02-01T09:22:50.737709603-03:00
rendered_js: false
word_count: 381
summary: This document explains how to configure workspace rules in Hyprland to customize workspace behavior, including layout settings, monitor binding, and gap configurations.
tags:
    - workspace-rules
    - hyprland
    - configuration
    - layout
    - monitor
    - gaps
category: reference
---

You can set workspace rules to achieve workspace-specific behaviors. For instance, you can define a workspace where all windows are drawn without borders or gaps.

For layout-specific rules, see the specific layout page. For example: [Master Layout-&gt;Workspace Rules](https://wiki.hypr.land/Configuring/Master-Layout#workspace-rules).

### Workspace selectors[](#workspace-selectors)

Workspaces that have already been created can be targeted by workspace selectors, e.g. `r[2-4] w[t1]`.

Selectors have props separated by a space. No spaces are allowed inside props themselves.

Props:

- `r[A-B]` - ID range from A to B inclusive
- `s[bool]` - Whether the workspace is special or not
- `n[bool]`, `n[s:string]`, `n[e:string]` - named actions. `n[bool]` -&gt; whether a workspace is a named workspace, `s` and `e` are starts and ends with respectively
- `m[monitor]` - Monitor selector
- `w[(flags)A-B]`, `w[(flags)X]` - Prop for window counts on the workspace. A-B is an inclusive range, X is a specific number. Flags can be omitted. It can be `t` for tiled-only, `f` for floating-only, `g` to count groups instead of windows, `v` to count only visible windows, and `p` to count only pinned windows.
- `f[-1]`, `f[0]`, `f[1]`, `f[2]` - fullscreen state of the workspace. `-1`: no fullscreen, `0`: fullscreen, `1`: maximized, `2`, fullscreen without fullscreen state sent to the window.

### Syntax[](#syntax)

- WORKSPACE is a valid workspace identifier (see [Dispatchers-&gt;Workspaces](https://wiki.hypr.land/Configuring/Dispatchers#workspaces)). This field is mandatory. This *can be* a workspace selector, but please note workspace selectors can only match *existing* workspaces.
- RULES is one (or more) rule(s) as described here in [rules](#rules).

### Examples[](#examples)

#### Smart gaps[](#smart-gaps)

To replicate “smart gaps” / “no gaps when only” from other WMs/Compositors, use this bad boy:

#### Smart gaps (ignoring special workspaces)[](#smart-gaps-ignoring-special-workspaces)

You can combine workspace selectors for more fine-grained control, for example, to ignore special workspaces:

## Rules[](#rules)

RuleDescriptiontypemonitor:\[m]Binds a workspace to a monitor. See [syntax](#syntax) and [Monitors](https://wiki.hypr.land/Configuring/Monitors).stringdefault:\[b]Whether this workspace should be the default workspace for the given monitorboolgapsin:\[x]Set the gaps between windows (equivalent to [General-&gt;gaps\_in](https://wiki.hypr.land/Configuring/Variables#general))intgapsout:\[x]Set the gaps between windows and monitor edges (equivalent to [General-&gt;gaps\_out](https://wiki.hypr.land/Configuring/Variables#general))intbordersize:\[x]Set the border size around windows (equivalent to [General-&gt;border\_size](https://wiki.hypr.land/Configuring/Variables#general))intborder:\[b]Whether to draw borders or notboolshadow:\[b]Whether to draw shadows or notboolrounding:\[b]Whether to draw rounded windows or notbooldecorate:\[b]Whether to draw window decorations or notboolpersistent:\[b]Keep this workspace alive even if empty and inactiveboolon-created-empty:\[c]A command to be executed once a workspace is created empty (i.e. not created by moving a window to it). See the [command syntax](https://wiki.hypr.land/Configuring/Dispatchers#executing-with-rules)stringdefaultName:\[s]A default name for the workspace.string

### Example Rules[](#example-rules)