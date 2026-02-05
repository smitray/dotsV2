---
title: Event list
url: https://wiki.hypr.land/Plugins/Development/Event-list/
source: sitemap
fetched_at: 2026-02-01T09:22:23.928789511-03:00
rendered_js: false
word_count: 318
summary: This document provides a comprehensive reference of all available event hooks that can be used with Hyprland's Event Hooks system, detailing their purposes, arguments, and cancellability.
tags:
    - event-hooks
    - hyprland
    - monitor
    - window
    - workspace
    - keyboard
    - mouse
    - touch
category: reference
---

These are all the events that can be listened to using Event Hooks.

## Complete list[](#complete-list)

Note

`M:` means `std::unordered_map<std::string, std::any>` following props are members.

namedescriptionargument(s)cancellabletickfired on a tick, meaning once per (1000 / highestMonitorHz) ms`nullptr`✕activeWindowfired on active window change`PHLWINDOW`✕keyboardFocusfired on keyboard focus change. Contains the newly focused surface`SP<CWLSurfaceResource>`✕moveWorkspacefired when a workspace changes its monitor`std::vector<std::any>{PHLWORKSPACE, PHLMONITOR}`✕focusedMonfired on monitor focus changePHLMONITOR✕moveWindowfired when a window changes workspace`std::vector<std::any>{PHLWINDOW, PHLWORKSPACE}`✕openLayerfired when a LS is mapped`PHLLS`✕closeLayerfired when a LS is unmapped`PHLLS`✕openWindowfired when a window is mapped`PHLWINDOW`✕closeWindowfired when a window is unmapped`PHLWINDOW`✕windowUpdateRulesfired when a window’s rules are updated`PHLWINDOW`✕urgentfired when a window requests urgent`PHLWINDOW`✕preMonitorAddedfired when a monitor is plugged in, before Hyprland handles it`PHLMONITOR`✕monitorAddedfired when a monitor is plugged in, after Hyprland has handled it`PHLMONITOR`✕preMonitorRemovedfired when a monitor is unplugged, before Hyprland handles it`PHLMONITOR`✕monitorRemovedfired when a monitor is unplugged, after Hypralnd has handled it`PHLMONITOR`✕createWorkspacefired when a workspace is created`PHLWORKSPACE`✕destroyWorkspacefired when a workspace is destroyed`PHLWORKSPACE`✕fullscreenfired when a window changes fullscreen state`PHLWINDOW`✕changeFloatingModefired when a window changes float state`PHLWINDOW`✕workspacefired on a workspace change (only ones explicitly requested by a user)`PHLWORKSPACE`✕submapfired on a submap change`std::string`✕mouseMovefired when the cursor moves. Param is coords.`const Vector2D`✔mouseButtonfired on a mouse button press`IPointer::SButtonEvent`✔mouseAxisfired on a mouse axis eventM: `event`:`IPointer::SAxisEvent`✔touchDownfired on a touch down event`ITouch::SDownEvent`✔touchUpfired on a touch up event`ITouch::SUpEvent`✔touchMovefired on a touch motion event`ITouch::SMotionEvent`✔activeLayoutfired on a keyboard layout change. String pointer temporary, not guaranteed after execution of the handler finishes.`std::vector<std::any>{SP<IKeyboard>, std::string}`✕preRenderfired before a frame for a monitor is about to be rendered`PHLMONITOR`✕screencastfired when the screencopy state of a client changes. Keep in mind there might be multiple separate clients.`std::vector<uint64_t>{state, framesInHalfSecond, owner}`✕renderfired at various stages of rendering to allow your plugin to render stuff. See `src/SharedDefs.hpp` for a list with explanations`eRenderStage`✕windowtitleemitted when a window title changes.`PHLWINDOW`✕configReloadedemitted after the config is reloaded`nullptr`✕preConfigReloademitted before a config reload`nullptr`✕keyPressemitted on a key pressM: `event`:`IKeyboard::SButtonEvent`, `keyboard`:`SP<IKeyboard>`✔pinemitted when a window is pinned or unpinned`PHLWINDOW`✕swipeBeginemitted when a touchpad swipe is commenced`IPointer::SSwipeBeginEvent`✔swipeUpdateemitted when a touchpad swipe is updated`IPointer::SSwipeUpdateEvent`✔swipeEndemitted when a touchpad swipe is ended`IPointer::SSwipeEndEvent`✔