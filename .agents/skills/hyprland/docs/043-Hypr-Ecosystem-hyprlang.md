---
title: hyprlang
url: https://wiki.hypr.land/Hypr-Ecosystem/hyprlang/
source: sitemap
fetched_at: 2026-02-01T09:23:27.894591095-03:00
rendered_js: false
word_count: 612
summary: This document provides comprehensive documentation for the hypr configuration language syntax and features, including variables, categories, comments, arithmetic operations, and conditional statements.
tags:
    - configuration-language
    - syntax-guide
    - hyprlang
    - config-parser
    - arithmetic-operations
    - conditionals
    - comments
category: reference
---

[hyprlang](https://github.com/hyprwm/hyprlang) is a library that implements parsing for the hypr configuration language.

## Syntax[](#syntax)

### Line Style[](#line-style)

Every config line is a command followed by a value.

The command can be a variable, or a special keyword (those are defined by the app you are using).

Variables are like “options”, while keywords are like “commands”.  
Options can be specified only once (if you do it more times, the previous one will be overwritten), while commands invoke some behavior every time they are defined.

The trailing spaces at the beginning and end of words are not necessary, and are there only for legibility.

### Categories[](#categories)

Categories can be regular, and “special”.

Both are specified in the same way:

Special categories can have other properties, like for example containing a key:

This is like defining two “groups”, one with the key of A, another with B.  
Hyprland for example uses those for per-device configs.

### Defining variables[](#defining-variables)

Variables can be defined like so:

Later on, you can use them like so:

Note

Spaces around or separating values are not mandatory

### Comments[](#comments)

Comments are started with the `#` character.

If you want to escape it (put an actual `#` and not start a comment) you can use `##`.  
It will be turned into a single `#` that *will* be a part of your line.

### Escaping Errors[](#escaping-errors)

If you use plugins, you may want to ignore errors from missing options/keywords so that you don’t get an error bar before they are loaded. To do so, do this:

### Inline Options[](#inline-options)

If you want to specify an option inline, without opening and closing a category, use the `:` separator:

If the category is special and requires a key, you can write:

This is the syntax used by `hyprctl keyword`, for example.

### Arithmetic Operations[](#arithmetic-operations)

Since 0.6.3, hyprlang supports *very* basic arithmetic operations on variables using `{{}}`

You can use `+`, `-`, `*`, or `/`, on only *two* variables (or constants) are a time.  
You *cannot* nest them, but you can use intermittent variables.

Example:

This may throw some errors if done incorrectly. Make sure that:

- you only have two sides to the operation (**NOT** `{{a + b + c}}`, that has three)
- both sides either exist as numeric variables or are numeric themselves
- you have spaces around the operator (**NOT** `{{a+b}}`)

### Arithmetic Escaping[](#arithmetic-escaping)

Since 0.6.4, hyprlang allows for escaping arithmetic expressions, e.g.`{{a + b}}`, by prefixing a `\`.  
They can be used on any of the starting positions of the expression braces.

Example:

This will not evaluate the expression, and instead just assign the raw value you wrote verbatim.  
All of the `\` that were used to escape will be removed from the value as well. So `\{{hello world}}` will turn into `{{hello world}}`, without trying to parse it as an expression.

### Escaping Escapes[](#escaping-escapes)

Since 0.6.4, you can escape any `\` that would have been used to escape other characters.

For example, if you want to have a `\` before a real expression:

If you want to have an `\` before any of the escapable characters:

### Conditionals[](#conditionals)

Since 0.6.4, you can add conditionals to your configs.  
You can make blocks conditional by using the `# hyprlang if` directive.

Some examples:

Some important information

- A variable is `true` if and only if it exists and is not an empty string.
- Environment variables are supported.
- Dynamic keywords (with `hyprctl keyword`) will **NOT** re-trigger or un-trigger these blocks.  
  Changes need to be made to the files directly (or environment) and in the case of the latter, or a hypr* app that doesn’t automatically reload its config, a relaunch of the app / `hyprctl reload` (for hl) will be required.

## Developer Documentation[](#developer-documentation)

See the documentation at [standards.hyprland.org/hyprlang](https://standards.hyprland.org/hyprlang/).