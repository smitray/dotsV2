---
title: PR Guidelines
url: https://wiki.hypr.land/Contributing-and-Debugging/PR-Guidelines/
source: sitemap
fetched_at: 2026-02-01T09:23:34.081756888-03:00
rendered_js: false
word_count: 559
summary: This document outlines the requirements and coding standards for contributing pull requests to the Hyprland project, covering code style, formatting, testing, and general development practices.
tags:
    - pull-request
    - code-style
    - clang-format
    - clang-tidy
    - coding-standards
    - hyprland
    - contribution-guidelines
category: guide
---

## PR Requirements[](#pr-requirements)

- Clean, not hacky code
- Described changes and *why* they were there
- Following the style (see below)

## Code Style[](#code-style)

Please read this if you are submitting a PR, in order to minimize the amount of style nits received, and save the time for the maintainers.

### Before you submit[](#before-you-submit)

Make sure you ran clang-format: `clang-format -i $(find src -type f \( -name "*.cpp" -o -name "*.hpp" \))`

Check if your changes don’t violate `clang-tidy`. Usually this is built into your IDE.

### Clang-format[](#clang-format)

This is non-negotiable. Your code **must** be formatted.

### Clang-tidy[](#clang-tidy)

Clang-tidy violations are not hard requirements, but please try to minimize them, and *only* ignore them if it’s absolutely necessary.

I’ve tweaked it so that in 99% of cases you absolutely should fix it.

### Testing[](#testing)

Please check the [Tests](https://wiki.hypr.land/Contributing-and-Debugging/Tests) page for information about tests in Hyprland, and related projects.

No test regressions is a *must*, while new tests are *required* if possible to test (e.g. graphical stuff is not testable).

### Other[](#other)

Some stuff clang-tidy / clang-format won’t catch:

- No uninitialized *primitives* (int, float, double, size\_t, etc.)
- No short if braces. if your if/else body contains 1 *line* (not 1 statement) do not put `{}` around it.
- The above rule does not apply to loops / etc
- Consider adding a `;` inside of empty function bodies
- Whenever you’re initializing vectors arrays or maps with a lot of elements, add a `,` after the last element to make the styling nicer
- Consider forward-declaring things in headers if possible instead of including. Speeds up compile times.
- no `using namespace std;`, and `using namespace (anything else)` is only allowed in source files, not headers.
- prefer guards rather than nesting. `if(!valid) return;` is much better than `if (valid) { /* a billion things */ }`

### Naming conventions[](#naming-conventions)

Although we’ve used hungarian notation in the past, we are moving away from it. The current, and new code, should use `camelCase` with an `m_` prefix if the variable is a member of a class. (not a struct)

Additionally:

- classes have a prefix of `C`: `CMyClass`
- structs have a prefix of `S`: `SMyStruct`
- interfaces have a prefix of `I`: `IMyInterface`
- global pointers for singletons have a prefix of `g_`: `g_someManager`
- constant variables are in CAPS: `const auto MYVARIABLE = ...`

## General code requirements[](#general-code-requirements)

### No raw pointers[](#no-raw-pointers)

This is a simple rule - don’t use raw pointers (e.g. `CMyClass*`) unless *absolutely necessary*. You have `UP`, `SP` and `WP` at your disposal. These are unique, shared and weak pointers respectively.

### No malloc[](#no-malloc)

Unless absolutely necessary, do not use malloc / free. You *will* forget to free the memory.

### Avoid dubious cleanups[](#avoid-dubious-cleanups)

If a function is a C-style allocator, e.g. `some_c_call_make_new()`, it will likely require a `some_c_call_free()`. In these cases, either:

- wrap the thing in a C++ class, or
- if used only within one function, use a `CScopeGuard` to always free it when the function exits.

### Use the STL[](#use-the-stl)

Generally, use the STL instead of trying to reinvent the wheel.

### Use hyprutils[](#use-hyprutils)

Hyprutils provides a lot of utilities that are well-suited for hyprland (and other hypr* projects) specifically. Use them.

### No absolute includes from /src[](#no-absolute-includes-from-src)

Imagine this scenario:

If you are in `a.hpp` and want to include `b.hpp`, you *must* use `../b/b.hpp`, and *cannot* use `b/b.hpp`. The latter will break plugins.

One exception you might notice in the code is absolute paths from the root are allowed, e.g. `protocols/some-protocol.hpp`.