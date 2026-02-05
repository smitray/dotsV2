---
title: Contributing and Debugging
url: https://wiki.hypr.land/Contributing-and-Debugging/
source: sitemap
fetched_at: 2026-02-01T09:23:09.509786831-03:00
rendered_js: false
word_count: 470
summary: This document provides comprehensive guidance on setting up a development environment for Hyprland, including building in debug mode, configuring development tools, and debugging techniques.
tags:
    - debug-mode
    - development-setup
    - build-process
    - gdb-debugging
    - vscode
    - cmake
    - hyprland
    - configuration
category: guide
---

PR, code styling and code FAQs are [here](https://wiki.hypr.land/Contributing-and-Debugging/PR-Guidelines)

For issues, please see [the guidelines](https://github.com/hyprwm/Hyprland/blob/main/docs/ISSUE_GUIDELINES.md)

## Build in debug mode[](#build-in-debug-mode)

### Required packages[](#required-packages)

See [manual build](https://wiki.hypr.land/Getting-Started/Installation/#manual-manual-build) for deps.

### Recommended, CMake[](#recommended-cmake)

Install the VSCode C/C++ and CMake Tools extensions and use that.

I’ve attached a [example/launch.json](https://github.com/hyprwm/Hyprland/blob/main/example/launch.json) that you can copy to your .vscode/ folder in the repo root.

With that, you can build in debug, go to the debugging tab and hit `(gdb) Launch`.

*note:* You probably want to set `watchdog_timeout = 0` in the debug {} section of your config. Otherwise Hyprland will notice its hanging when you hit a breakpoint and it will crash after you continue out of it.

### Custom, CLI[](#custom-cli)

`make debug`

Attach and profile in your preferred way.

### Nix[](#nix)

To build the package in debug mode, you have to override it like this:

This code can go in the `package` attribute of the NixOS/Home Manager modules.

## Development environment[](#development-environment)

### Setup[](#setup)

Make a copy of your config in `~/.config/hypr` called `hyprlandd.conf`. `Debug` builds automatically use `hyprlandd.conf`, but you can also pass `--config ~/path/to/conf.conf` for an override on release / different file.

#### Recommended debug config changes[](#recommended-debug-config-changes)

- remove *all* `exec=` or `exec-once=` directives from your config.
- change default modifier for binds (e.g. `SUPER` -&gt; `ALT`)

#### Launch the dev env[](#launch-the-dev-env)

Launch the output `Hyprland` binary in `./build/` *when logged into a Hyprland session*.

A new window should open with Hyprland running inside of it. You can now test stuff in the nested session without worrying about nuking your actual session, and also being able to debug it easily. I’d also recommend to launch Hyprland with some sort of a debugger, like `gdb`. Your IDE (if you use one) can likely do it for you, otherwise `gdb ./build/Hyprland` should suffice. This will help you debug crashes.

For gdb, when Hyprland crashes, gdb will stop and allow you to inspect the current state with commands like `bt`, `frame`, `print`, etc. An IDE will allow you to do it graphically.

## LSP and Formatting[](#lsp-and-formatting)

If you want proper LSP support in an editor that doesn’t automatically set it up, use clangd. You’ll probably notice there will be a bunch of warnings because we haven’t generated compile commands, to do this run:

Also, before submitting a PR please format with clang-format, to run this only on your changes run `git-clang-format` in your projects root directory.

## Logs, dumps, etc[](#logs-dumps-etc)

You can use the logs and the GDB debugger, but running Hyprland in debug compile as a driver and using it for a while might give more insight to the more random bugs.

When Hyprland crashes, use `coredumpctl` and then `coredumpctl info PID` to see the dump. See the instructions below for more info about `coredumpctl`.

You can also use the amazing command

for live logs. (replace `hyprland` with `hyprlandd` for debug builds)

### How do I get a coredump?[](#how-do-i-get-a-coredump)

See [`ISSUE_GUIDELINES.md`](https://github.com/hyprwm/Hyprland/blob/main/docs/ISSUE_GUIDELINES.md).