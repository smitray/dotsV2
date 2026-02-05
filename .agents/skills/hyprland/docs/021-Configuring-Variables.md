---
title: Variables
url: https://wiki.hypr.land/Configuring/Variables/
source: sitemap
fetched_at: 2026-02-01T09:22:19.613051275-03:00
rendered_js: false
word_count: 4356
summary: This document serves as a comprehensive reference for configuring Hyprland's various options, covering general settings, decoration parameters, animation controls, and layout-specific configurations.
tags:
    - hyprland
    - configuration
    - settings
    - options
    - decoration
    - animation
    - layout
category: reference
---

For basic syntax info, see [Configuring Hyprland](https://wiki.hypr.land/Configuring/).

This page documents all the “options” of Hyprland. For binds, monitors, animations, etc. see the sidebar. For anything else, see [Keywords](https://wiki.hypr.land/Configuring/Keywords).

Please keep in mind some options that are layout-specific will be documented in the layout pages and not here. (See the Sidebar for Dwindle and Master layouts)

## Variable types[](#variable-types)

typedescriptionintintegerboolboolean, `true` or `false` (`yes` or `no`, `on` or `off`, `0` or `1`) - any numerical value that is not `0` or `1` will cause undefined behavior.floatfloating point numbercolorcolor (see hint below for color info)vec2vector with 2 float values, separated by a space (e.g. `0 0` or `-10.9 99.1`)MODa string modmask (e.g. `SUPER` or `SUPERSHIFT` or `SUPER + SHIFT` or `SUPER and SHIFT` or `CTRL_SHIFT` or empty for none. You are allowed to put any separators you please except for a `,`)stra stringgradienta gradient, in the form of `color color ... [angle]` where `color` is a color (see above) and angle is an angle in degrees, in the format of `123deg` e.g. `45deg` (e.g. `rgba(11ee11ff) rgba(1111eeff) 45deg`) Angle is optional and will default to `0deg`font\_weightan integer between 100 and 1000, or one of the following presets: `thin` `ultralight` `light` `semilight` `book` `normal` `medium` `semibold` `bold` `ultrabold` `heavy` `ultraheavy`

**Colors**

You have 3 options:

- rgba(), e.g. `rgba(b3ff1aee)`, or the decimal equivalent `rgba(179,255,26,0.933)` (decimal rgba/rgb values should have no spaces between numbers)
- rgb(), e.g. `rgb(b3ff1a)`, or the decimal equivalent `rgb(179,255,26)`
- legacy, e.g. `0xeeb3ff1a` -&gt; ARGB order

## Sections[](#sections)

### General[](#general)

namedescriptiontypedefaultborder\_sizesize of the border around windowsint1gaps\_ingaps between windows, also supports css style gaps (top, right, bottom, left -&gt; 5,10,15,20)int5gaps\_outgaps between windows and monitor edges, also supports css style gaps (top, right, bottom, left -&gt; 5,10,15,20)int20float\_gapsgaps between windows and monitor edges for floating windows, also supports css style gaps (top, right, bottom, left -&gt; 5 10 15 20). -1 means defaultint0gaps\_workspacesgaps between workspaces. Stacks with gaps\_out.int0col.inactive\_borderborder color for inactive windowsgradient0xff444444col.active\_borderborder color for the active windowgradient0xffffffffcol.nogroup\_borderinactive border color for window that cannot be added to a group (see `denywindowfromgroup` dispatcher)gradient0xffffaaffcol.nogroup\_border\_activeactive border color for window that cannot be added to a groupgradient0xffff00fflayoutwhich layout to use. \[dwindle/master]strdwindleno\_focus\_fallbackif true, will not fall back to the next available window when moving focus in a direction where no window was foundboolfalseresize\_on\_borderenables resizing windows by clicking and dragging on borders and gapsboolfalseextend\_border\_grab\_areaextends the area around the border where you can click and drag on, only used when `general:resize_on_border` is on.int15hover\_icon\_on\_bordershow a cursor icon when hovering over borders, only used when `general:resize_on_border` is on.booltrueallow\_tearingmaster switch for allowing tearing to occur. See [the Tearing page](https://wiki.hypr.land/Configuring/Tearing).boolfalseresize\_cornerforce floating windows to use a specific corner when being resized (1-4 going clockwise from top left, 0 to disable)int0modal\_parent\_blockingwhether parent windows of modals will be interactivebooltruelocaleoverrides the system locale (e.g. en\_US, es)str\[\[Empty]]

#### Snap[](#snap)

*Subcategory `general:snap:`*

namedescriptiontypedefaultenabledenable snapping for floating windowsboolfalsewindow\_gapminimum gap in pixels between windows before snappingint10monitor\_gapminimum gap in pixels between window and monitor edges before snappingint10border\_overlapif true, windows snap such that only one border’s worth of space is between themboolfalserespect\_gapsif true, snapping will respect gaps between windows(set in general:gaps\_in)boolfalse

Important

A subcategory is a nested category:

Doing `general:snap {` is **invalid**!

### Decoration[](#decoration)

namedescriptiontypedefaultroundingrounded corners’ radius (in layout px)int0rounding\_poweradjusts the curve used for rounding corners, larger is smoother, 2.0 is a circle, 4.0 is a squircle, 1.0 is a triangular corner. \[1.0 - 10.0]float2.0active\_opacityopacity of active windows. \[0.0 - 1.0]float1.0inactive\_opacityopacity of inactive windows. \[0.0 - 1.0]float1.0fullscreen\_opacityopacity of fullscreen windows. \[0.0 - 1.0]float1.0dim\_modalenables dimming of parents of modal windowsbooltruedim\_inactiveenables dimming of inactive windowsboolfalsedim\_strengthhow much inactive windows should be dimmed \[0.0 - 1.0]float0.5dim\_specialhow much to dim the rest of the screen by when a special workspace is open. \[0.0 - 1.0]float0.2dim\_aroundhow much the `dim_around` window rule should dim by. \[0.0 - 1.0]float0.4screen\_shadera path to a custom shader to be applied at the end of rendering. See `examples/screenShader.frag` for an example.str\[\[Empty]]border\_part\_of\_windowwhether the window border should be a part of the windowbooltrue

#### Blur[](#blur)

*Subcategory `decoration:blur:`*

namedescriptiontypedefaultenabledenable kawase window background blurbooltruesizeblur size (distance)int8passesthe amount of passes to performint1ignore\_opacitymake the blur layer ignore the opacity of the windowbooltruenew\_optimizationswhether to enable further optimizations to the blur. Recommended to leave on, as it will massively improve performance.booltruexrayif enabled, floating windows will ignore tiled windows in their blur. Only available if new\_optimizations is true. Will reduce overhead on floating blur significantly.boolfalsenoisehow much noise to apply. \[0.0 - 1.0]float0.0117contrastcontrast modulation for blur. \[0.0 - 2.0]float0.8916brightnessbrightness modulation for blur. \[0.0 - 2.0]float0.8172vibrancyIncrease saturation of blurred colors. \[0.0 - 1.0]float0.1696vibrancy\_darknessHow strong the effect of `vibrancy` is on dark areas . \[0.0 - 1.0]float0.0specialwhether to blur behind the special workspace (note: expensive)boolfalsepopupswhether to blur popups (e.g. right-click menus)boolfalsepopups\_ignorealphaworks like ignore\_alpha in layer rules. If pixel opacity is below set value, will not blur. \[0.0 - 1.0]float0.2input\_methodswhether to blur input methods (e.g. fcitx5)boolfalseinput\_methods\_ignorealphaworks like ignore\_alpha in layer rules. If pixel opacity is below set value, will not blur. \[0.0 - 1.0]float0.2

Note

`blur:size` and `blur:passes` have to be at least 1.

Increasing `blur:passes` is necessary to prevent blur looking wrong on higher `blur:size` values, but remember that higher `blur:passes` will require more strain on the GPU.

#### Shadow[](#shadow)

*Subcategory `decoration:shadow:`*

namedescriptiontypedefaultenabledenable drop shadows on windowsbooltruerangeShadow range (“size”) in layout pxint4render\_powerin what power to render the falloff (more power, the faster the falloff) \[1 - 4]int3sharpif enabled, will make the shadows sharp, akin to an infinite render powerboolfalseignore\_windowif true, the shadow will not be rendered behind the window itself, only around it.booltruecolorshadow’s color. Alpha dictates shadow’s opacity.color0xee1a1a1acolor\_inactiveinactive shadow color. (if not set, will fall back to color)colorunsetoffsetshadow’s rendering offset.vec2\[0, 0]scaleshadow’s scale. \[0.0 - 1.0]float1.0

### Animations[](#animations)

namedescriptiontypedefaultenabledenable animationsbooltrueworkspace\_wraparoundenable workspace wraparound, causing directional workspace animations to animate as if the first and last workspaces were adjacentboolfalse

### Input[](#input)

namedescriptiontypedefaultkb\_modelAppropriate XKB keymap parameter. See the note below.str\[\[Empty]]kb\_layoutAppropriate XKB keymap parameterstruskb\_variantAppropriate XKB keymap parameterstr\[\[Empty]]kb\_optionsAppropriate XKB keymap parameterstr\[\[Empty]]kb\_rulesAppropriate XKB keymap parameterstr\[\[Empty]]kb\_fileIf you prefer, you can use a path to your custom .xkb file.str\[\[Empty]]numlock\_by\_defaultEngage numlock by default.boolfalseresolve\_binds\_by\_symDetermines how keybinds act when multiple layouts are used. If false, keybinds will always act as if the first specified layout is active. If true, keybinds specified by symbols are activated when you type the respective symbol with the current layout.boolfalserepeat\_rateThe repeat rate for held-down keys, in repeats per second.int25repeat\_delayDelay before a held-down key is repeated, in milliseconds.int600sensitivitySets the mouse input sensitivity. Value is clamped to the range -1.0 to 1.0. [libinput#pointer-acceleration](https://wayland.freedesktop.org/libinput/doc/latest/pointer-acceleration.html#pointer-acceleration)float0.0accel\_profileSets the cursor acceleration profile. Can be one of `adaptive`, `flat`. Can also be `custom`, see [below](#custom-accel-profiles). Leave empty to use `libinput`’s default mode for your input device. [libinput#pointer-acceleration](https://wayland.freedesktop.org/libinput/doc/latest/pointer-acceleration.html#pointer-acceleration) \[adaptive/flat/custom]str\[\[Empty]]force\_no\_accelForce no cursor acceleration. This bypasses most of your pointer settings to get as raw of a signal as possible. **Enabling this is not recommended due to potential cursor desynchronization.**boolfalserotationSets the rotation of a device in degrees clockwise off the logical neutral position. Value is clamped to the range 0 to 359.int0left\_handedSwitches RMB and LMBboolfalsescroll\_pointsSets the scroll acceleration profile, when `accel_profile` is set to `custom`. Has to be in the form `<step> <points>`. Leave empty to have a flat scroll curve.str\[\[Empty]]scroll\_methodSets the scroll method. Can be one of `2fg` (2 fingers), `edge`, `on_button_down`, `no_scroll`. [libinput#scrolling](https://wayland.freedesktop.org/libinput/doc/latest/scrolling.html) \[2fg/edge/on\_button\_down/no\_scroll]str\[\[Empty]]scroll\_buttonSets the scroll button. Has to be an int, cannot be a string. Check `wev` if you have any doubts regarding the ID. 0 means default.int0scroll\_button\_lockIf the scroll button lock is enabled, the button does not need to be held down. Pressing and releasing the button toggles the button lock, which logically holds the button down or releases it. While the button is logically held down, motion events are converted to scroll events.boolfalsescroll\_factorMultiplier added to scroll movement for external mice. Note that there is a separate setting for [touchpad scroll\_factor](#touchpad).float1.0natural\_scrollInverts scrolling direction. When enabled, scrolling moves content directly, rather than manipulating a scrollbar.boolfalsefollow\_mouseSpecify if and how cursor movement should affect window focus. See the note below. \[0/1/2/3]int1follow\_mouse\_thresholdThe smallest distance in logical pixels the mouse needs to travel for the window under it to get focused. Works only with follow\_mouse = 1.float0.0focus\_on\_closeControls the window focus behavior when a window is closed. When set to 0, focus will shift to the next window candidate. When set to 1, focus will shift to the window under the cursor. \[0/1]int0mouse\_refocusIf disabled, mouse focus won’t switch to the hovered window unless the mouse crosses a window boundary when `follow_mouse=1`.booltruefloat\_switch\_override\_focusIf enabled (1 or 2), focus will change to the window under the cursor when changing from tiled-to-floating and vice versa. If 2, focus will also follow mouse on float-to-float switches.int1special\_fallthroughif enabled, having only floating windows in the special workspace will not block focusing windows in the regular workspace.boolfalseoff\_window\_axis\_eventsHandles axis events around (gaps/border for tiled, dragarea/border for floated) a focused window. `0` ignores axis events `1` sends out-of-bound coordinates `2` fakes pointer coordinates to the closest point inside the window `3` warps the cursor to the closest point inside the windowint1emulate\_discrete\_scrollEmulates discrete scrolling from high resolution scrolling events. `0` disables it, `1` enables handling of non-standard events only, and `2` force enables all scroll wheel events to be handledint1

**Follow Mouse Cursor**

- 0 - Cursor movement will not change focus.
- 1 - Cursor movement will always change focus to the window under the cursor.
- 2 - Cursor focus will be detached from keyboard focus. Clicking on a window will move keyboard focus to that window.
- 3 - Cursor focus will be completely separate from keyboard focus. Clicking on a window will not change keyboard focus.

**Custom Accel Profiles**

#### `accel_profile`[](#accel_profile)

`custom <step> <points...>`

Example: `custom 200 0.0 0.5`

#### `scroll_points`[](#scroll_points)

NOTE: Only works when `accel_profile` is set to `custom`.

`<step> <points...>`

Example: `0.2 0.0 0.5 1 1.2 1.5`

To mimic the Windows acceleration curves, take a look at [this script](https://gist.github.com/fufexan/de2099bc3086f3a6c83d61fc1fcc06c9).

See [the libinput doc](https://wayland.freedesktop.org/libinput/doc/latest/pointer-acceleration.html) for more insights on how it works.

#### Touchpad[](#touchpad)

*Subcategory `input:touchpad:`*

namedescriptiontypedefaultdisable\_while\_typingDisable the touchpad while typing.booltruenatural\_scrollInverts scrolling direction. When enabled, scrolling moves content directly, rather than manipulating a scrollbar.boolfalsescroll\_factorMultiplier applied to the amount of scroll movement.float1.0middle\_button\_emulationSending LMB and RMB simultaneously will be interpreted as a middle click. This disables any touchpad area that would normally send a middle click based on location. [libinput#middle-button-emulation](https://wayland.freedesktop.org/libinput/doc/latest/middle-button-emulation.html)boolfalsetap\_button\_mapSets the tap button mapping for touchpad button emulation. Can be one of `lrm` (default) or `lmr` (Left, Middle, Right Buttons). \[lrm/lmr]str\[\[Empty]]clickfinger\_behaviorButton presses with 1, 2, or 3 fingers will be mapped to LMB, RMB, and MMB respectively. This disables interpretation of clicks based on location on the touchpad. [libinput#clickfinger-behavior](https://wayland.freedesktop.org/libinput/doc/latest/clickpad-softbuttons.html#clickfinger-behavior)boolfalsetap-to-clickTapping on the touchpad with 1, 2, or 3 fingers will send LMB, RMB, and MMB respectively.booltruedrag\_lockWhen enabled, lifting the finger off while dragging will not drop the dragged item. 0 -&gt; disabled, 1 -&gt; enabled with timeout, 2 -&gt; enabled sticky. [libinput#tap-and-drag](https://wayland.freedesktop.org/libinput/doc/latest/tapping.html#tap-and-drag)int0tap-and-dragSets the tap and drag mode for the touchpadbooltrueflip\_xinverts the horizontal movement of the touchpadboolfalseflip\_yinverts the vertical movement of the touchpadboolfalsedrag\_3fgenables three finger drag, 0 -&gt; disabled, 1 -&gt; 3 fingers, 2 -&gt; 4 fingers [libinput#drag-3fg](https://wayland.freedesktop.org/libinput/doc/latest/drag-3fg.html)int0

#### Touchdevice[](#touchdevice)

*Subcategory `input:touchdevice:`*

namedescriptiontypedefaulttransformTransform the input from touchdevices. The possible transformations are the same as [those of the monitors](https://wiki.hypr.land/Configuring/Monitors/#rotating). `-1` means it’s unset.int-1outputThe monitor to bind touch devices. The default is auto-detection. To stop auto-detection, use an empty string or the “\[\[Empty]]” value.string\[\[Auto]]enabledWhether input is enabled for touch devices.booltrue

#### Virtualkeyboard[](#virtualkeyboard)

*Subcategory `input:virtualkeyboard:`*

namedescriptiontypedefaultshare\_statesUnify key down states and modifier states with other keyboards. 0 -&gt; no, 1 -&gt; yes, 2 -&gt; yes unless IME clientint2release\_pressed\_on\_closeRelease all pressed keys by virtual keyboard on close.boolfalse

#### Tablet[](#tablet)

*Subcategory `input:tablet:`*

namedescriptiontypedefaulttransformtransform the input from tablets. The possible transformations are the same as [those of the monitors](https://wiki.hypr.land/Configuring/Monitors/#rotating). `-1` means it’s unset.int-1outputthe monitor to bind tablets. Can be `current` or a monitor name. Leave empty to map across all monitors.string\[\[Empty]]region\_positionposition of the mapped region in monitor layout relative to the top left corner of the bound monitor or all monitors.vec2\[0, 0]absolute\_region\_positionwhether to treat the `region_position` as an absolute position in monitor layout. Only applies when `output` is empty.boolfalseregion\_sizesize of the mapped region. When this variable is set, tablet input will be mapped to the region. \[0, 0] or invalid size means unset.vec2\[0, 0]relative\_inputwhether the input should be relativeboolfalseleft\_handedif enabled, the tablet will be rotated 180 degreesboolfalseactive\_area\_sizesize of tablet’s active area in mmvec2\[0, 0]active\_area\_positionposition of the active area in mmvec2\[0, 0]

### Per-device input config[](#per-device-input-config)

Described [here](https://wiki.hypr.land/Configuring/Keywords#per-device-input-configs).

### Gestures[](#gestures)

*Subcategory `gestures:`*

namedescriptiontypedefaultworkspace\_swipe\_distancein px, the distance of the touchpad gestureint300workspace\_swipe\_touchenable workspace swiping from the edge of a touchscreenboolfalseworkspace\_swipe\_invertinvert the direction (touchpad only)booltrueworkspace\_swipe\_touch\_invertinvert the direction (touchscreen only)boolfalseworkspace\_swipe\_min\_speed\_to\_forceminimum speed in px per timepoint to force the change ignoring `cancel_ratio`. Setting to `0` will disable this mechanic.int30workspace\_swipe\_cancel\_ratiohow much the swipe has to proceed in order to commence it. (0.7 -&gt; if &gt; 0.7 * distance, switch, if less, revert) \[0.0 - 1.0]float0.5workspace\_swipe\_create\_newwhether a swipe right on the last workspace should create a new one.booltrueworkspace\_swipe\_direction\_lockif enabled, switching direction will be locked when you swipe past the `direction_lock_threshold` (touchpad only).booltrueworkspace\_swipe\_direction\_lock\_thresholdin px, the distance to swipe before direction lock activates (touchpad only).int10workspace\_swipe\_foreverif enabled, swiping will not clamp at the neighboring workspaces but continue to the further ones.boolfalseworkspace\_swipe\_use\_rif enabled, swiping will use the `r` prefix instead of the `m` prefix for finding workspaces.boolfalseclose\_max\_timeoutthe timeout for a window to close when using a 1:1 gesture, in msint1000

Note

`workspace_swipe`, `workspace_swipe_fingers` and `workspace_swipe_min_fingers` were removed in favor of the new gestures system.

You can add this gesture config to replicate the swiping functionality with 3 fingers. See the [gestures](https://wiki.hypr.land/Configuring/Gestures) page for more info.

### Group[](#group)

*Subcategory `group:`*

namedescriptiontypedefaultauto\_groupwhether new windows will be automatically grouped into the focused unlocked group. Note: if you want to disable auto\_group only for specific windows, use [the “group barred” window rule](https://wiki.hypr.land/Configuring/Window-Rules/#group-window-rule-options) instead.booltrueinsert\_after\_currentwhether new windows in a group spawn after current or at group tailbooltruefocus\_removed\_windowwhether Hyprland should focus on the window that has just been moved out of the groupbooltruedrag\_into\_groupwhether dragging a window into a unlocked group will merge them. Options: 0 (disabled), 1 (enabled), 2 (only when dragging into the groupbar)int1merge\_groups\_on\_dragwhether window groups can be dragged into other groupsbooltruemerge\_groups\_on\_groupbarwhether one group will be merged with another when dragged into its groupbarbooltruemerge\_floated\_into\_tiled\_on\_groupbarwhether dragging a floating window into a tiled window groupbar will merge themboolfalsegroup\_on\_movetoworkspacewhether using movetoworkspace\[silent] will merge the window into the workspace’s solitary unlocked groupboolfalsecol.border\_activeactive group border colorgradient0x66ffff00col.border\_inactiveinactive (out of focus) group border colorgradient0x66777700col.border\_locked\_activeactive locked group border colorgradient0x66ff5500col.border\_locked\_inactiveinactive locked group border colorgradient0x66775500

#### Groupbar[](#groupbar)

*Subcategory `group:groupbar:`*

namedescriptiontypedefaultenabledenables groupbarsbooltruefont\_familyfont used to display groupbar titles, use `misc:font_family` if not specifiedstring\[\[Empty]]font\_sizefont size of groupbar titleint8font\_weight\_activefont weight of active groupbar titlefont\_weightnormalfont\_weight\_inactivefont weight of inactive groupbar titlefont\_weightnormalgradientsenables gradientsboolfalseheightheight of the groupbarint14indicator\_gapheight of gap between groupbar indicator and titleint0indicator\_heightheight of the groupbar indicatorint3stackedrender the groupbar as a vertical stackboolfalseprioritysets the decoration priority for groupbarsint3render\_titleswhether to render titles in the group bar decorationbooltruetext\_offsetadjust vertical position for titlesint0text\_paddingset horizontal padding for titlesint0scrollingwhether scrolling in the groupbar changes group active windowbooltrueroundinghow much to round the indicatorint1rounding\_poweradjusts the curve used for rounding groupbar corners, larger is smoother, 2.0 is a circle, 4.0 is a squircle, 1.0 is a triangular corner. \[1.0 - 10.0]float2.0gradient\_roundinghow much to round the gradientsint2gradient\_rounding\_poweradjusts the curve used for rounding gradient corners, larger is smoother, 2.0 is a circle, 4.0 is a squircle, 1.0 is a triangular corner. \[1.0 - 10.0]float2.0round\_only\_edgesround only the indicator edges of the entire groupbarbooltruegradient\_round\_only\_edgesround only the gradient edges of the entire groupbarbooltruetext\_colorcolor for window titles in the groupbarcolor0xfffffffftext\_color\_inactivecolor for inactive windows’ titles in the groupbar (if unset, defaults to text\_color)colorunsettext\_color\_locked\_activecolor for the active window’s title in a locked group (if unset, defaults to text\_color)colorunsettext\_color\_locked\_inactivecolor for inactive windows’ titles in locked groups (if unset, defaults to text\_color\_inactive)colorunsetcol.activeactive group bar background colorgradient0x66ffff00col.inactiveinactive (out of focus) group bar background colorgradient0x66777700col.locked\_activeactive locked group bar background colorgradient0x66ff5500col.locked\_inactiveinactive locked group bar background colorgradient0x66775500gaps\_ingap size between gradientsint2gaps\_outgap size between gradients and windowint2keep\_upper\_gapadd or remove upper gapbooltrueblurapplies blur to the groupbar indicators and gradientsboolfalse

### Misc[](#misc)

*Subcategory `misc:`*

namedescriptiontypedefaultdisable\_hyprland\_logodisables the random Hyprland logo / anime girl background. :(boolfalsedisable\_splash\_renderingdisables the Hyprland splash rendering. (requires a monitor reload to take effect)boolfalsedisable\_scale\_notificationdisables notification popup when a monitor fails to set a suitable scaleboolfalsecol.splashChanges the color of the splash text (requires a monitor reload to take effect).color0xfffffffffont\_familySet the global default font to render the text including debug fps/notification, config error messages and etc., selected from system fonts.stringSanssplash\_font\_familyChanges the font used to render the splash text, selected from system fonts (requires a monitor reload to take effect).string\[\[Empty]]force\_default\_wallpaperEnforce any of the 3 default wallpapers. Setting this to `0` or `1` disables the anime background. `-1` means “random”. \[-1/0/1/2]int-1vfrcontrols the VFR status of Hyprland. Heavily recommended to leave enabled to conserve resources.booltruevrrcontrols the VRR (Adaptive Sync) of your monitors. 0 - off, 1 - on, 2 - fullscreen only, 3 - fullscreen with `video` or `game` content type \[0/1/2/3]int0mouse\_move\_enables\_dpmsIf DPMS is set to off, wake up the monitors if the mouse moves.boolfalsekey\_press\_enables\_dpmsIf DPMS is set to off, wake up the monitors if a key is pressed.boolfalsename\_vk\_after\_procName virtual keyboards after the processes that create them. E.g. /usr/bin/fcitx5 will have hl-virtual-keyboard-fcitx5.booltruealways\_follow\_on\_dndWill make mouse focus follow the mouse when drag and dropping. Recommended to leave it enabled, especially for people using focus follows mouse at 0.booltruelayers\_hog\_keyboard\_focusIf true, will make keyboard-interactive layers keep their focus on mouse move (e.g. wofi, bemenu)booltrueanimate\_manual\_resizesIf true, will animate manual window resizes/movesboolfalseanimate\_mouse\_windowdraggingIf true, will animate windows being dragged by mouse, note that this can cause weird behavior on some curvesboolfalsedisable\_autoreloadIf true, the config will not reload automatically on save, and instead needs to be reloaded with `hyprctl reload`. Might save on battery.boolfalseenable\_swallowEnable window swallowingboolfalseswallow\_regexThe *class* regex to be used for windows that should be swallowed (usually, a terminal). To know more about the list of regex which can be used [use this cheatsheet](https://github.com/ziishaned/learn-regex/blob/master/README.md).str\[\[Empty]]swallow\_exception\_regexThe *title* regex to be used for windows that should *not* be swallowed by the windows specified in swallow\_regex (e.g. wev). The regex is matched against the parent (e.g. Kitty) window’s title on the assumption that it changes to whatever process it’s running.str\[\[Empty]]focus\_on\_activateWhether Hyprland should focus an app that requests to be focused (an `activate` request)boolfalsemouse\_move\_focuses\_monitorWhether mouse moving into a different monitor should focus itbooltrueallow\_session\_lock\_restoreif true, will allow you to restart a lockscreen app in case it crashesboolfalsesession\_lock\_xrayif true, keep rendering workspaces below your lockscreenboolfalsebackground\_colorchange the background color. (requires enabled `disable_hyprland_logo`)color0x111111close\_special\_on\_emptyclose the special workspace if the last window is removedbooltrueon\_focus\_under\_fullscreenif there is a fullscreen or maximized window, decide whether a tiled window requested to focus should replace it, stay behind or disable the fullscreen/maximized state. 0 - ignore focus request (keep focus on fullscreen window), 1 - takes over, 2 - unfullscreen/unmaximize \[0/1/2]int2exit\_window\_retains\_fullscreenif true, closing a fullscreen window makes the next focused window fullscreenboolfalseinitial\_workspace\_trackingif enabled, windows will open on the workspace they were invoked on. 0 - disabled, 1 - single-shot, 2 - persistent (all children too)int1middle\_click\_pastewhether to enable middle-click-paste (aka primary selection)booltruerender\_unfocused\_fpsthe maximum limit for render\_unfocused windows’ fps in the background (see also [Window-Rules](https://wiki.hypr.land/Configuring/Window-Rules/#dynamic-effects) - `render_unfocused`)int15disable\_xdg\_env\_checksdisable the warning if XDG environment is externally managedboolfalsedisable\_hyprland\_qtutils\_checkdisable the warning if hyprland-qtutils is not installedboolfalselockdead\_screen\_delaydelay after which the “lockdead” screen will appear in case a lockscreen app fails to cover all the outputs (5 seconds max)int1000enable\_anr\_dialogwhether to enable the ANR (app not responding) dialog when your apps hangbooltrueanr\_missed\_pingsnumber of missed pings before showing the ANR dialogint5size\_limits\_tiledwhether to apply min\_size and max\_size rules to tiled windowsboolfalsedisable\_watchdog\_warningwhether to disable the warning about not using start-hyprlandboolfalse

### Binds[](#binds)

*Subcategory `binds:`*

namedescriptiontypedefaultpass\_mouse\_when\_boundif disabled, will not pass the mouse events to apps / dragging windows around if a keybind has been triggered.boolfalsescroll\_event\_delayin ms, how many ms to wait after a scroll event to allow passing another one for the binds.int300workspace\_back\_and\_forthIf enabled, an attempt to switch to the currently focused workspace will instead switch to the previous workspace. Akin to i3’s *auto\_back\_and\_forth*.boolfalsehide\_special\_on\_workspace\_changeIf enabled, changing the active workspace (including to itself) will hide the special workspace on the monitor where the newly active workspace resides.boolfalseallow\_workspace\_cyclesIf enabled, workspaces don’t forget their previous workspace, so cycles can be created by switching to the first workspace in a sequence, then endlessly going to the previous workspace.boolfalseworkspace\_center\_onWhether switching workspaces should center the cursor on the workspace (0) or on the last active window for that workspace (1)int0focus\_preferred\_methodsets the preferred focus finding method when using `focuswindow`/`movewindow`/etc with a direction. 0 - history (recent have priority), 1 - length (longer shared edges have priority)int0ignore\_group\_lockIf enabled, dispatchers like `moveintogroup`, `moveoutofgroup` and `movewindoworgroup` will ignore lock per group.boolfalsemovefocus\_cycles\_fullscreenIf enabled, when on a fullscreen window, `movefocus` will cycle fullscreen, if not, it will move the focus in a direction.boolfalsemovefocus\_cycles\_groupfirstIf enabled, when in a grouped window, movefocus will cycle windows in the groups first, then at each ends of tabs, it’ll move on to other windows/groupsboolfalsedisable\_keybind\_grabbingIf enabled, apps that request keybinds to be disabled (e.g. VMs) will not be able to do so.boolfalsewindow\_direction\_monitor\_fallbackIf enabled, moving a window or focus over the edge of a monitor with a direction will move it to the next monitor in that direction.booltrueallow\_pin\_fullscreenIf enabled, Allow fullscreen to pinned windows, and restore their pinned status afterwardsboolfalsedrag\_thresholdMovement threshold in pixels for window dragging and c/g bind flags. 0 to disable and grab on mousedown.int0

### XWayland[](#xwayland)

*Subcategory `xwayland:`*

namedescriptiontypedefaultenabledallow running applications using X11booltrueuse\_nearest\_neighboruses the nearest neighbor filtering for xwayland apps, making them pixelated rather than blurrybooltrueforce\_zero\_scalingforces a scale of 1 on xwayland windows on scaled displays.boolfalsecreate\_abstract\_socketCreate the [abstract Unix domain socket](https://wiki.hypr.land/Configuring/XWayland/#abstract-unix-domain-socket) for XWayland connections. (XWayland restart is required for changes to take effect; Linux only)boolfalse

### OpenGL[](#opengl)

*Subcategory `opengl:`*

namedescriptiontypedefaultnvidia\_anti\_flickerreduces flickering on nvidia at the cost of possible frame drops on lower-end GPUs. On non-nvidia, this is ignored.booltrue

### Render[](#render)

*Subcategory `render:`*

namedescriptiontypedefaultdirect\_scanoutEnables direct scanout. Direct scanout attempts to reduce lag when there is only one fullscreen application on a screen (e.g. game). It is also recommended to set this to false if the fullscreen application shows graphical glitches. 0 - off, 1 - on, 2 - auto (on with content type ‘game’)int0expand\_undersized\_texturesWhether to expand undersized textures along the edge, or rather stretch the entire texture.booltruexp\_modeDisables back buffer and bottom layer rendering.boolfalsectm\_animationWhether to enable a fade animation for CTM changes (hyprsunset). 2 means “auto” which disables them on Nvidia.int2cm\_fs\_passthroughPassthrough color settings for fullscreen apps when possible. 0 - off, 1 - always, 2 - hdr onlyint2cm\_enabledWhether the color management pipeline should be enabled or not (requires a restart of Hyprland to fully take effect)booltruesend\_content\_typeReport content type to allow monitor profile autoswitch (may result in a black screen during the switch)booltruecm\_auto\_hdrAuto-switch to HDR in fullscreen when needed. 0 - off, 1 - switch to `cm, hdr`, 2 - switch to `cm, hdredid`int1new\_render\_schedulingAutomatically uses triple buffering when needed, improves FPS on underpowered devices.boolfalsenon\_shader\_cmEnable CM without shader. 0 - disable, 1 - whenever possible, 2 - DS and passthrough only, 3 - disable and ignore CM issuesint3cm\_sdr\_eotfDefault transfer function for displaying SDR apps. 0 - Default (currently gamma22), 1 - Treat unspecified as Gamma 2.2, 2 - Treat unspecified and sRGB as Gamma 2.2, 3 - Treat unspecified as sRGB (previous default)int0

`cm_auto_hdr` requires `--target-colorspace-hint-mode=source` mpv option to work with mpv versions greater than v0.40.0

### Cursor[](#cursor)

*Subcategory `cursor:`*

namedescriptiontypedefaultinvisibledon’t render cursorsboolfalsesync\_gsettings\_themesync xcursor theme with gsettings, it applies cursor-theme and cursor-size on theme load to gsettings making most CSD gtk based clients use same xcursor theme and size.booltrueno\_hardware\_cursorsdisables hardware cursors. 0 - use hw cursors if possible, 1 - don’t use hw cursors, 2 - auto (disable when tearing)int2no\_break\_fs\_vrrdisables scheduling new frames on cursor movement for fullscreen apps with VRR enabled to avoid framerate spikes (may require no\_hardware\_cursors = true) 0 - off, 1 - on, 2 - auto (on with content type ‘game’)int2min\_refresh\_rateminimum refresh rate for cursor movement when `no_break_fs_vrr` is active. Set to minimum supported refresh rate or higherint24hotspot\_paddingthe padding, in logical px, between screen edges and the cursorint1inactive\_timeoutin seconds, after how many seconds of cursor’s inactivity to hide it. Set to `0` for never.float0no\_warpsif true, will not warp the cursor in many cases (focusing, keybinds, etc)boolfalsepersistent\_warpsWhen a window is refocused, the cursor returns to its last position relative to that window, rather than to the centre.boolfalsewarp\_on\_change\_workspaceMove the cursor to the last focused window after changing the workspace. Options: 0 (Disabled), 1 (Enabled), 2 (Force - ignores cursor:no\_warps option)int0warp\_on\_toggle\_specialMove the cursor to the last focused window when toggling a special workspace. Options: 0 (Disabled), 1 (Enabled), 2 (Force - ignores cursor:no\_warps option)int0default\_monitorthe name of a default monitor for the cursor to be set to on startup (see `hyprctl monitors` for names)str\[\[EMPTY]]zoom\_factorthe factor to zoom by around the cursor. Like a magnifying glass. Minimum 1.0 (meaning no zoom)float1.0zoom\_rigidwhether the zoom should follow the cursor rigidly (cursor is always centered if it can be) or looselyboolfalsezoom\_detached\_cameradetach the camera from the mouse when zoomed in, only ever moving the camera to keep the mouse in view when it goes past the screen edgesbooltrueenable\_hyprcursorwhether to enable hyprcursor supportbooltruehide\_on\_key\_pressHides the cursor when you press any key until the mouse is moved.boolfalsehide\_on\_touchHides the cursor when the last input was a touch input until a mouse input is done.booltruehide\_on\_tabletHides the cursor when the last input was a tablet input until a mouse input is done.booltrueuse\_cpu\_bufferMakes HW cursors use a CPU buffer. Required on Nvidia to have HW cursors. 0 - off, 1 - on, 2 - auto (nvidia only)int2warp\_back\_after\_non\_mouse\_inputWarp the cursor back to where it was after using a non-mouse input to move it, and then returning back to mouse.boolfalsezoom\_disable\_aadisable antialiasing when zooming, which means things will be pixelated instead of blurryboolfalse

### Ecosystem[](#ecosystem)

*Subcategory `ecosystem:`*

namedescriptiontypedefaultno\_update\_newsdisable the popup that shows up when you update hyprland to a new version.boolfalseno\_donation\_nagdisable the popup that shows up twice a year encouraging to donate.boolfalseenforce\_permissionswhether to enable [permission control](https://wiki.hypr.land/Configuring/Permissions).boolfalse

### Quirks[](#quirks)

*Subcategory `quirks:`*

namedescriptiontypedefaultprefer\_hdrReport HDR mode as preferred. 0 - off, 1 - always, 2 - gamescope onlyint0

Some clients expect monitor to be in HDR mode prior to the client start. This breaks auto HDR activation and can cause whitescreen and flickering. Use `prefer_hdr` to fix it,

### Debug[](#debug)

*Subcategory `debug:`*

namedescriptiontypedefaultoverlayprint the debug performance overlay. Disable VFR for accurate results.boolfalsedamage\_blink(epilepsy warning!) flash areas updated with damage trackingboolfalsedisable\_logsdisable logging to a filebooltruedisable\_timedisables time loggingbooltruedamage\_trackingredraw only the needed bits of the display. Do **not** change. (default: full - 2) monitor - 1, none - 0int2enable\_stdout\_logsenables logging to stdoutboolfalsemanual\_crashset to 1 and then back to 0 to crash Hyprland.int0suppress\_errorsif true, do not display config file parsing errors.boolfalsewatchdog\_timeoutsets the timeout in seconds for watchdog to abort processing of a signal of the main thread. Set to 0 to disable.int5disable\_scale\_checksdisables verification of the scale factors. Will result in pixel alignment and rounding errors.boolfalseerror\_limitlimits the number of displayed config file parsing errors.int5error\_positionsets the position of the error bar. top - 0, bottom - 1int0colored\_stdout\_logsenables colors in the stdout logs.booltruepassenables render pass debugging.boolfalsefull\_cm\_protoclaims support for all cm proto features (requires restart)boolfalse

### More[](#more)

There are more config options described in other pages, which are layout- or circumstance-specific. See the sidebar for more pages.