---
title: hyprlock
url: https://wiki.hypr.land/Hypr-Ecosystem/hyprlock/
source: sitemap
fetched_at: 2026-02-01T09:22:36.234505597-03:00
rendered_js: false
word_count: 1655
summary: This document provides comprehensive documentation for hyprlock, a fast and GPU-accelerated screen locker for Hyprland, covering installation, configuration, command-line usage, and widget customization.
tags:
    - screen-lock
    - hyprland
    - gpu-accelerated
    - configuration
    - authentication
    - widgets
    - pam
    - keyboard-shortcuts
category: reference
---

[hyprlock](https://github.com/hyprwm/hyprlock) is a simple, yet fast, multi-threaded and GPU-accelerated screen lock for Hyprland.

Warning

Hyprlock does not automatically create a config, and without one, hyprlock will *not render anything*.  
But even without a config, your session will get locked and thus Hyprland will cover your session with a black screen.  
You can unlock normally by typing your password followed by hitting Enter, but you won’t have any visual feedback.

You can use the example config for a quick start, which can be found [here](https://github.com/hyprwm/hyprlock/blob/main/assets/example.conf).

## Command-line Arguments[](#command-line-arguments)

See also: `hyprlock --help`.

argumentdescription`-v` | `--verbose`Enable verbose logging`-q` | `--quiet`Disable logging`-c` FILE | `--config` FILESpecify config file to use`--display` NAMESpecify the wayland display to connect to`--grace` SECONDSSet grace period in seconds before requiring authentication`--immediate-render`Do not wait for resources before drawing the background (Same as `general:immediate_render`)`--no-fade-in`Disable the fade-in animation when the lock screen appears`-V` | `--version`Show version information and exit`-h` | `--help`Show help and exit

## Configuration[](#configuration)

Configuration is done via the config file at `~/.config/hypr/hyprlock.conf`. This file must exist to run `hyprlock`.

### Variable Types[](#variable-types)

Hyprlock uses the following types in addition to [Hyprland’s variable types](https://wiki.hypr.land/Configuring/Variables#Variable_types).

typedescriptionlayoutxyvec2 with an optional `%` suffix, allowing users to specify sizes as percentages of the output size.  
Floats (e.g. 10.5) are supported, but only have an effect when used with `%`.  
Raw pixel values will just get rounded.

### General[](#general)

Variables in the `general` category:

VariableDescriptionTypeDefault`hide_cursor`Hides the cursor instead of making it visible.bool`false``ignore_empty_input`Skips validation when no password is provided.bool`false``immediate_render`Makes hyprlock immediately start to draw widgets.  
Backgrounds will render `background:color` until their `background:path` resource is available.bool`false``text_trim`Sets if the text should be trimmed, useful to avoid trailing newline in commands output.bool`true``fractional_scaling`Whether to use fractional scaling.  
`0`: disabled  
`1`: enabled  
`2`: autoint`2``screencopy_mode`Selects screencopy mode:  
`0`: gpu accelerated  
`1`: cpu based (slow)int`0``fail_timeout`Milliseconds until the ui resets after a failed auth attemptint`2000`

### Authentication[](#authentication)

Variables in the `auth` category:

VariableDescriptionTypeDefault`pam:enabled`Whether to enable pam authentication.bool`true``pam:module`Sets the pam module used for authentication. If the module isn’t found in `/etc/pam.d`, “su” will be used as a fallback.str`hyprlock``fingerprint:enabled`Enables parallel fingerprint auth with fprintd.bool`false``fingerprint:ready_message`Sets the message that will be displayed when fprintd is ready to scan a fingerprint.str`(Scan fingerprint to unlock)``fingerprint:present_message`Sets the message that will be displayed when a finger is placed on the scanner.str`Scanning fingerprint``fingerprint:retry_delay`Sets the delay in ms after an unrecognized finger is scanned before another finger can be scanned.int`250`

Note

At least one enabled authentication method is required.

### Animations[](#animations)

Variables in the `animations` category:

variabledescriptiontypedefaultenabledwhether to enable animationsbool`true`

#### Keywords[](#keywords)

The `animation` and `bezier` keywords can be used just like in `hyprland.conf`.

For Example:

Available animations can be found in the [animation tree](#animation-tree). The optional `STYLE` parameter for the `animation` keyword is currently unused by hyprlock.

Check out Hyprland’s [animation documentation](https://wiki.hypr.land/Configuring/Animations) for more information.

#### Animation Tree[](#animation-tree)

### System Configuration[](#system-configuration)

On Arch Linux, by default, hyprlock integrates with [pambase](https://archlinux.org/packages/?name=pambase) through `pam_faillock.so`, which forces a 10 minute timeout after 3 failed unlocks.  
If you would like to change this, refer to the [arch linux wiki](https://wiki.archlinux.org/title/Security#Lock_out_user_after_three_failed_login_attempts) and update the file `/etc/security/faillock.conf` file with parameters `unlock_time`, `fail_interval`, and `deny` as needed.

## Keyboard Shortcuts and Actions[](#keyboard-shortcuts-and-actions)

The following keys and key-combinations describe hyprlock’s default behaviour:

inputdescription`ESC`Clear password buffer`Ctrl + u`Clear password buffer`Ctrl + Backspace`Clear password buffer

The [bind flag](https://wiki.hypr.land/Configuring/Binds/#bind-flags) `l` can be used to allow specific hyprland keybinds to also work while hyprlock is active (e.g. brightness/volume/media control).

## Widgets[](#widgets)

The entire configuration of how hyprlock looks is done via widgets.

### Monitor Selection[](#monitor-selection)

`monitor` is available for all widgets and can be left empty for “all monitors”.

It takes the same string that is used to reference monitors in the hyprland configuration. So either use the portname (e.g. `eDP-1`) or the monitor description (e.g. `desc:Chimei Innolux Corporation 0x150C`).

See [Monitors](https://wiki.hypr.land/Configuring/Monitors).

### Variable Substitution[](#variable-substitution)

The following variables in widget text options will be substituted.

- `$USER` - username (e.g. linux-user)
- `$DESC` - user description (e.g. Linux User)
- `$TIME` - current time in 24-hour format (e.g. `13:37`)
- `$TIME12` - current time in 12-hour format (e.g. `1:37 PM`)
- `$LAYOUT` - current keyboard layout
- `$ATTEMPTS` - failed authentication attempts
- `$FAIL` - last authentication fail reason
- `$PAMPROMPT` - pam auth last prompt
- `$PAMFAIL` - pam auth last fail reason
- `$FPRINTPROMPT` - fingerprint auth last prompt
- `$FPRINTFAIL` - fingerprint auth last fail reason

## Widget List[](#widget-list)

### General Remarks[](#general-remarks)

- All rendered text supports [pango markup](https://docs.gtk.org/Pango/pango_markup.html).
  
  - Additionally hyprlock will parse `<br/>` for your convenience. (That’s a linebreak) Remember to enable linebreaks in your spans with `allow_breaks="true"`.
- Positioning is done via halign, valign, position, and zindex. Position is an added offset to the result of alignment.
  
  - halign: `left`, `center`, `right`, `none`. valign: `top`, `center`, `bottom`, `none`
  - zindex: Widgets with larger numbers will be placed above widgets with smaller numbers. All widgets default to 0, except background which defaults to -1.
- All `position` and `size` options can be specified in pixels or as percentages of the output size.
  
  - pixels: `10, 10` or `10px, 10px`
  - percentages: `10%, 10.5%`
  - mixed: `10%, 5px`
- Supported image formats are png, jpg and webp (no animations though)

### Shadowable[](#shadowable)

Some widgets are shadowable, meaning they can have a shadow. For those widgets, you get:

VariableDescriptionTypeDefault`shadow_passes`Passes for shadow, 0 to disable.int`0``shadow_size`Size for shadow.int`3``shadow_color`Shadow color.color`rgb(0,0,0)``shadow_boost`Boost shadow’s opacity.float`1.2`

### Clickable[](#clickable)

Some widgets are clickable. Namely `label`, `image` and `shape`.  
You can launch arbitrary commands when clicking on them by configuring the following option within the widget:

variabledescriptiontypedefault`onclick`Command to run when clicked.strempty

### Background[](#background)

Draws a background image or fills with color.  
If `path` is empty or missing, will use `color`, otherwise, the image will be used.

If `path` is `screenshot`, a screenshot of your desktop at launch will be used.

VariableDescriptionTypeDefault`monitor`Monitor to draw on.strempty`path`Image path, `screenshot` or empty to fill with `color`.strempty`color`Fallback background colorcolor`rgba(17, 17, 17, 1.0)``blur_passes`The amount of passes to perform.  
`0` disables blurring.int`0``blur_size`Blur size (distance).int`7``noise`How much noise to apply.float`0.0117``contrast`Contrast modulation for blur.float`0.8916``brightness`Brightness modulation for blur.float`0.8172``vibrancy`Increase saturation of blurred colors.float`0.1696``vibrancy_darkness`How strong the effect of vibrancy is on dark areas.float`0.05``reload_time`Seconds between reloading, `0` to reload with `SIGUSR2`.  
Ignored if `path` is `screenshot`.int`-1``reload_cmd`Command to get new path. If empty, old path will be used.strempty`crossfade_time`Cross-fade time in seconds between old and new background on reload.  
A negative value means no cross-fade.float`-1.0``zindex`z-index of the widget.int`-1`

**Example background**

### Image[](#image)

✓ Shadowable  
✓ Clickable

Draws an image.

If `path` is empty or missing, nothing will be shown.

VariableDescriptionTypeDefault`monitor`Monitor to draw onstr*empty*`path`Image pathstr*empty*`size`Size scale based on the lesser side of the image.int`150``rounding`Negative values result in a circle.int`-1``border_size`Border size.int`4``border_color`Border color.gradient`rgba(221, 221, 221, 1.0)``rotate`Rotation in degrees, counter-clockwise.int`0``reload_time`Seconds between reloading, `0` to reload with `SIGUSR2`.int`-1``reload_cmd`Command to get new path. if empty, old path will be used. don’t run “follow” commands like `tail -F`.str*empty*`position`Position of the image.layoutxy`0, 0``halign`Horizontal alignment.str`center``valign`Vertical alignment.str`center``zindex`z-index of the widget.int`0`

**Example image**

### Shape[](#shape)

✓ Shadowable  
✓ Clickable

Draws a shape.

VariableDescriptionTypeDefault`monitor`Monitor to draw on.str*empty*`size`Size of the shape.layoutxy100, 100`color`Color of the shape.color`rgba(17, 17, 17, 1.0)``rounding`Negative values result in a circle.int`-1``rotate`Rotation in degrees, counter-clockwise.int`0``border_size`Border size.int`0``border_color`Border color.gradient`rgba(0, 207, 230, 1.0)``xray`If `true`, make a “hole” in the background (rectangle of specified size, no rotation).bool`false``position`Position of the shape.layoutxy`0, 0``halign`Horizontal alignment.str`center``valign`Vertical alignment.str`center``zindex`z-index of the widget.int`0`

**Example shape**

### Input Field[](#input-field)

✓ Shadowable

Draws a password input field.

VariableDescriptionTypeDefault`monitor`Monitor to draw on.str*empty*`size`Size of the input field.layoutxy`400, 90``outline_thickness`Thickness of the outline.int`4``dots_size`Size of the dots. \[0.2 - 0.8]float`0.25``dots_spacing`Spacing between dots. \[-1.0 - 1.0]float`0.15``dots_center`Whether to center the dots. Align left otherwise.bool`true``dots_rounding`Rounding of the dots.int`-1``dots_text_format`Text character(s) used for the input indicator, rounded rectangles are the default.str*empty*`outer_color`Border color.gradient`rgba(17, 17, 17, 1.0)``inner_color`Color of the inner box.color`rgba(200, 200, 200, 1.0)``font_color`Color of the font.color`rgba(10, 10, 10, 1.0)``font_family`Font family.str`Noto Sans``fade_on_empty`Fade the input field when empty.bool`true``fade_timeout`Milliseconds before `fade_on_empty` is triggered.int`2000``placeholder_text`Text rendered in the input box when it’s empty.str`<i>Input Password...</i>``hide_input`Render an input indicator similar to swaylock instead of dots when set to `true`.bool`false``hide_input_base_color`This color’s hue is randomly rotated (oklab color space) to get colors for `hide_input`.color`rgba(153, 170, 187)``rounding``-1` means complete rounding (circle/oval).int`-1``check_color`Color accent when waiting for the authentication result.gradient`rgba(204, 136, 34, 1.0)``fail_color`Color accent when authentication fails.gradient`rgba(204, 34, 34, 1.0)``fail_text`Text rendered when authentication fails.str`<i>$FAIL <b>($ATTEMPTS)</b></i>``capslock_color`Color accent when capslock is active.gradient*empty*`numlock_color`Color accent when numlock is active.gradient*empty*`bothlock_color`Color accent when both locks are active.gradient*empty*`invert_numlock`Change color if numlock is off.bool`false``swap_font_color`Swap font and inner colors on color change events.bool`false``position`Position of the input field.layoutxy`0, 0``halign`Horizontal alignment.str`center``valign`Vertical alignment.str`center``zindex`z-index of the widget.int`0`

**Colors information**

When `outline_thickness` set to `0`, the color of the inner box will be changed instead of the outer.  
Behaviour of `swap_font_color` is as follows:

- `outline_thickness` is `0`: if set, font color will be swapped with inner one on color change events (e.g. Caps-lock on or password check).
- `outline_thickness` is not `0`: if set, font and inner colors will be swapped on password check and authentication failure.
- `swap_font_color` will narrow the accent colors from a gradient to a single color by using the first specified color.

`placeholder_text` and `fail_text` both support [variable substitution](#variable-substitution).

**Example input-field**

### Label[](#label)

✓ Shadowable  
✓ Clickable

Draws a label.

VariableDescriptionTypeDefault`monitor`Monitor to draw on.str*empty*`text`Text to render.str`Sample Text``text_align`Multi-line text alignment inside label container. center/right or any value for default left.str`center``color`Color of the text.color`rgba(254, 254, 254, 1.0)``font_size`Size of the font.int`16``font_family`Font family.str`Sans``rotate`Rotation in degrees, counter-clockwise.int`0``position`Position of the label.layoutxy`0, 0``halign`Horizontal alignment.str`center``valign`Vertical alignment.str`center`

#### Dynamic Labels[](#dynamic-labels)

The `text` option supports [variable substitution](#variable-substitution) and launching shell commands.  
For example:

Note

- `update:` time is in ms.
- label can be forcefully updated by specifying `update:<time>:1` or `update:<time>:true` and sending `SIGUSR2` to hyprlock, `<time>` can be `0` in this case.
- `$ATTEMPTS[<string>]` format can be used to show `<string>` when there are no failed attempts.  
  You can use pango-markup here. `<string>` can be empty to hide.
- `$LAYOUT[<str0>,<str1>,...]` format is available to replace indexed layouts.  
  You can use settings from `hyprland.conf`, e.g. `$LAYOUT[en,ru,de]`.  
  Also, a single `!` character will hide layout. E.g. `$LAYOUT[!]` will hide default (0 indexed) and show others.
- `$TIME` and `$TIME12` will use timezone from the TZ environment variable.  
  If it’s not set, the system timezone will be used, falling back to UTC in case of errors.
- Variables seen above are parsed *before* the command is ran.
- **Do not** run commands that never exit. This will hang the `AsyncResourceGatherer` and you won’t have a good time.

**Example label**

## User Signals[](#user-signals)

- `SIGUSR1`: Unlocks hyprlock. For example, you can switch to a another tty and run `pkill -USR1 hyprlock`.
- `SIGUSR2`: Updates labels and images. See above.