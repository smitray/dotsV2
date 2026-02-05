---
title: Development
url: https://wiki.hypr.land/Hypr-Ecosystem/hyprtoolkit/development/
source: sitemap
fetched_at: 2026-02-01T09:23:23.578603991-03:00
rendered_js: false
word_count: 652
summary: This document provides a comprehensive guide to using Hyprtoolkit, a C++ toolkit for creating graphical applications with a retained mode layout system. It covers getting started, layout concepts, element usage, and advanced features like system icons and file descriptor handling.
tags:
    - cpp
    - gui
    - layout-system
    - retained-mode
    - elements
    - backend
    - system-icons
    - file-descriptor
category: guide
---

Hyprtoolkit is a pure C++ toolkit. It relies on modern C++ in the Hyprland style (with hyprutils, etc).

It’s recommended you are familiar with C++ before developing an app.

## Getting Started[](#getting-started)

*If you prefer living off of examples, see the `tests/` directory in the hyprtoolkit repo.*

Start by creating a backend and opening a window:

this will create (but not yet open) a window handle for you.

Hyprtoolkit is a retained mode toolkit, so you can define your layout with C++ and forget about it.

First thing we need is a background rectangle, by doing this:

Note

Remember to always use the palette when possible for your app to adhere to the user’s theme.

All elements are under `hyprtoolkit/elements/`, you can browse through them. Let’s add a simple layout with some buttons:

This adds a column layout (elements are stacked on top of each other) with two buttons. These buttons have automatic sizing, so will fit their contents.

Once you are done, add a close callback, open the window and enter the main loop:

## Layout System[](#layout-system)

The layout system relies on absolute and layout positioning modes. Let’s zoom into both:

### Absolute Mode[](#absolute-mode)

This happens when the parent of your element is anything but a `ColumnLayout` or a `RowLayout`. Children are positioned within their parent, according to their position mode. You can set it with `setPositionMode` and add offsets with `setAbsolutePosition`.

For example:

- `setPositionMode` with `CENTER` will center the child inside the parent.
- `setPositionMode` with `ABSOLUTE` will make it be in the top left corner.
- Adding `setAbsolutePosition` to the above with `{200, 200}` will move it 200 layout px down and right from the top left corner of the parent.

### Layout Mode[](#layout-mode)

This happens when the parent of your element is a layout. These will attempt to position your child elements. They work similarly to CSS’s `flex` and qt’s `RowLayout` and `ColumnLayout`, but will not wrap. If elements overflow and cannot shrink, they will disappear.

RowLayout positions elements next to each other side-by-side, while ColumnLayout does it top-bottom.

### Size[](#size)

All elements carry a `SizeType`. This tells the layout system how to size the element.

- `ABSOLUTE` takes layout px as size and makes the element rigid.
- `PERCENT` takes a percentage in the form of `(0, 0) - (1, 1)` and will be the size of the parent multiplied by the percentage.
- `AUTO` ignores the passed vector (leave it empty) and instead will always attempt to contain the children*

Note

Some elements will force their own sizing, e.g. `Text`.  
Leave them `AUTO` to avoid confusion.

## Elements[](#elements)

Most elements are self-explanatory. You can explore their builder functions to see what styling / behavior options they support.

Each element is created with a `Builder` which is there to maintain ABI stability. After you call `->commence()`, you will get a `SP` to the newly created object.

You can rebuild the object at any time by calling `->rebuild()` and you’ll get a builder again. **Remember to call `commence()` after you are done to apply the changes!**

You do not need to keep the `SP` after adding the element to the tree with `addChild`.

## Other[](#other)

Other, miscellaneous stuff

### System Icons[](#system-icons)

Use the `CBackend::systemIcons()` function to obtain a reference to `ISystemIconFactory` which allows you to query system icons by name.  
You can check the obtained result object to see if the icon was found.  
Then, you can take that object and slap it into an `ImageElement` to add it to your layout.

### Additional FDs[](#additional-fds)

If you have an app that depends on some other loop, e.g. pipewire, dbus, etc. you need to remember that hyprtoolkit is strictly single-threaded for layout and rendering.  
You cannot edit the layout from another thread.

For this, use `CBackend::addFd()` to add a FD to the loop alongside a function that will be called once the fd is readable.  
This function will be called from the main thread, so you can do whatever you want in there.