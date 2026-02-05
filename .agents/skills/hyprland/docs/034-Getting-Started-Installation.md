---
title: Installation
url: https://wiki.hypr.land/Getting-Started/Installation/
source: sitemap
fetched_at: 2026-02-01T09:22:06.409927121-03:00
rendered_js: false
word_count: 656
summary: This document provides comprehensive installation and setup guidance for Hyprland, a dynamic window manager that requires users to independently manage applications and integrations. It covers official support distributions, package installation methods, compilation options, and troubleshooting for common issues.
tags:
    - hyprland
    - window-manager
    - installation
    - linux
    - desktop-environment
    - troubleshooting
    - nvidia
    - compilation
category: guide
---

Warning

Hyprland is not meant to be a full and user-friendly Desktop Environment. In a nutshell, it’s a set of tools to allow you to create your own Desktop Environment.

Apps, integrations, shells, etc, are **your** responsibility to pick, install and configure.

This wiki is *very* verbose. It’s highly recommended to scour and read the wiki first before assuming something is not working or not available.

Note

NVIDIA GPUs are often not usable out-of-the-box, follow the [Nvidia page](https://wiki.hypr.land/Nvidia) after installing Hyprland if you plan to use one. Blame NVIDIA for this.

## Distros[](#distros)

We officially run and test Hyprland on Arch and NixOS, and we guarantee Hyprland will work there. For any other distro (not based on Arch/Nix) you might have varying amounts of success. However, since Hyprland is extremely bleeding-edge, point release distros like Pop!\_OS, Fedora, Ubuntu, etc. will have **major** issues running Hyprland. Rolling release distros like openSUSE, Solus ,etc. will likely be fine.

## Installation[](#installation)

Installing Hyprland is very easy. Simply install it with your package manager.

Warning

It is **heavily** recommended you use **what the distro packages for you**, and **not** compiling manually or using `-git` packages. Hyprland’s ecosystem and dependencies are vast and intertwined, and compiling manually will only potentially expose you to outdated, or incompatible versions of these dependencies.

If you get `.so` file mismatch / missing errors, it’s *entirely your fault* for doing this!

However, if you are an experienced user and want to beta-test new features, you’re more than welcome to run the latest git head. Please don’t come asking about “.so file missing” errors though!

### Packages[](#packages)

**WARNING:** I do not maintain any packages. If they are broken, try building from source first.

**Arch**

**Nix**

**openSUSE\***

**Fedora\***

**Debian\***

**Gentoo\***

**FreeBSD\***

**Ubuntu\***

**Void Linux\***

**Slackware\***

**Alpine\***

**Ximper\***

**Solus\***

**** Unofficial, no official support is provided. These instructions are community-driven, and no guarantee is provided for their validity.***

### Manual[](#manual)

Dependencies:

Note

Please note that Hyprland uses the C++26 standard, so both your compiler and your C++ standard library has to support that (`gcc>=15` or `clang>=19`).

**Arch**

**openSUSE**

**FreeBSD**

**Ubuntu**

refer to the Ubuntu tab above

Warning

Additionally to those, you will also need a few hypr* dependencies which may or may not be packaged for your distro of choice:

- aquamarine
- hyprlang
- hyprcursor
- hyprutils
- hyprgraphics
- hyprwayland-scanner (build-only)

### CMake (recommended)[](#cmake-recommended)

*CMake is always recommended as it’s the intended way Hyprland should be installed.*

## Crash on launch[](#crash-on-launch)

See [Crashes and Bugs](https://wiki.hypr.land/Crashes-and-Bugs).

## Custom installation (debug build, etc)[](#custom-installation-debug-build-etc)

1. cd into the hyprland repo.
2. for debug build:

<!--THE END-->

3. Any other config: (replace `<PRESET>` with your preset: `release`, `debug`)

## Custom Build flags[](#custom-build-flags)

To apply custom build flags, you’ll have to ditch make.

Supported custom build flags on CMake:

Flags can be passed to CMake like this:

Change `<FLAG>` to one of the custom build flags. Multiple flags can be used at once, by adding more `-D<FLAG_2>:STRING=true`.

The `BUILD_TYPE` can also be changed to `Debug`.

To build, run:

If you configured in `Debug`, change the `--config` to `Debug` as well.

To install, run:

## Running In a VM[](#running-in-a-vm)

*YMMV, this is not officially supported.*

Read through the [libvirt Arch wiki page](https://wiki.archlinux.org/title/Libvirt) and get `libvirt`, `virsh`, and `virt-viewer` setup and installed.

Go to the [arch-boxes gitlab](https://gitlab.archlinux.org/archlinux/arch-boxes/-/packages) and download the latest arch qemu basic image. You can also download via any of arch’s mirrors.

Create the VM with virsh.

Connect with `virt-viewer`, this will open a `virt-viewer` graphical session on the tty. The default login is ‘arch’ for user and ‘arch’ for password.

Warning

Make sure the –attach flag is used, enabling virgl makes it so that we had to disable listen. This means that we can’t make a direct TCP/UNIX socket connection to the remote display. –attach asks libvirt to provide a pre-connected socket to the display.*

Finally on the guest follow the instructions above for either [installing hyprland-git from the aur](#installation) or [building manually](#manual-manual-build).

Warning

Make sure you install `mesa` as the OpenGL driver. The virgl drivers are included in `mesa`.