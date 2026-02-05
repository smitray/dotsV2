---
title: hyprsunset
url: https://wiki.hypr.land/Hypr-Ecosystem/hyprsunset/
source: sitemap
fetched_at: 2026-02-01T09:22:59.062015779-03:00
rendered_js: false
word_count: 386
summary: Provides instructions for installing, configuring, and using hyprsunset, a blue light and gamma filter utility for Hyprland window manager that works alongside screen recordings and screenshots.
tags:
    - blue-light-filter
    - gamma-control
    - hyprland
    - display-brightness
    - systemd-service
    - ipc-control
    - screen-filter
    - monitor-settings
category: guide
---

[hyprsunset](https://github.com/hyprwm/hyprsunset) is a small utility to provide a blue light filter for your system.

This method is preferred to screen shaders as it will *not* be captured via recording / screenshots.

hyprsunset also provides a gamma filter, which can be used to adjust perceived display brightness on monitors that do not support software control, or to reduce perceived brightness below the monitor’s minimum.

Warning

`hyprsunset` is supported since Hyprland 0.45.0.

## Installation[](#installation)

## Configuration[](#configuration)

Configuration is done via the config file at `~/.config/hypr/hyprsunset.conf`.  
This file is not required for running hyprsunset, though recommended.

Hyprsunset uses profiles to determine when to change temperature and gamma.  
You can define as many profiles as you like.  
Each Profile is activated at it’s specified time and resets all options set by other profiles.

On startup, hyprsunset will apply the current profile.  
For example, when launching hyprsunset with the following example config at 20:00, it will activate the first profile, essentially changing nothing.  
Once the clock strikes 21:00, hyprsunset will automatically apply the new profile.

**Example Configuration**

VariableDescriptionTypeDefault`max-gamma`The maximum the gamma value can be.  
Absolute maximum is `200`%.  
Mostly useful when controlling hyprsunset via IPC.int`100`

### Profile[](#profile)

VariableDescriptionTypeDefault`time`The time at which the profile should be activated.  
Must be in the format {hours}:{minutes}string`00:00``temperature`The screen temperature. Lower means warmer.int`6000``gamma`The perceived brightness of the screen.  
This will allow you to lower the brightness beyond your screen’s minimum.float`1.0``identity`When set, the value of temperature is ignored and the only effect of hyprsunset is the change in apparent brightness by gamma.bool`false`

## Usage[](#usage)

To autostart hyprsunset, add: `exec-once = hyprsunset` to your `hyprland.conf`. Alternatively, use `systemctl --user enable --now hyprsunset.service` in order to use hyprsunset as a systemd user service.

Hyprsunset can also be controlled by supplying arguments to the command.  
By specifying `hyprsunset --temperature 5000` you will override the current active config’s temperature setting. This however, will be overridden once a new profile is activated.

For more information on cli arguments, run `hyprsunset --help`

## IPC[](#ipc)

`hyprsunset` supports IPC via hyprctl.  
Both color temperature and the gamma filter are adjustable:

This can be used by other software to change the temperature throughout the day, or to adjust perceieved monitor brightness, such as with the following Hyprland keybinds:

Warning

Using the gamma control will degrade color accuracy. If your monitor does support software control, it is highly recommended to use that instead.