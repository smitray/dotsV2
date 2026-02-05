---
title: Translations
url: https://wiki.hypr.land/Contributing-and-Debugging/Translations/
source: sitemap
fetched_at: 2026-02-01T09:23:36.247971695-03:00
rendered_js: false
word_count: 239
summary: This document explains how to contribute translations to Hyprland applications by describing where to find translation files and how to submit translations via GitHub merge requests.
tags:
    - translation
    - localization
    - hyprland
    - contribution
    - i18n
    - open-source
category: guide
---

Some parts of the Hyprland ecosystem are localized. More and more are getting localization frameworks. This is a short page showing how to contribute translations to Hyprland apps.

## Find the translation file[](#find-the-translation-file)

Here you’ll find a list of translation files for hyprapps ready to translate:

- [hyprland](https://github.com/hyprwm/Hyprland/blob/main/src/i18n/Engine.cpp)
- [hyprlauncher](https://github.com/hyprwm/hyprlauncher/blob/main/src/i18n/Engine.cpp)
- [hyprpwcenter](https://github.com/hyprwm/hyprpwcenter/blob/main/src/i18n/Engine.cpp)

*more are coming, this list will be updated*

## Translate[](#translate)

Translations are in C++, but they are straightforward, and don’t require much expertise. You submit a translation via a traditional MR on Github.

### Basic translations (unconditional)[](#basic-translations-unconditional)

You register a translation for a key and your language code. For example, for key `TXT_KEY_HELLO`, and language `pl_PL` (polish), you can:

Some translations have variables, included like so:

### Conditional translations[](#conditional-translations)

In some languages, you might want to change your translation based on e.g. the amount. (apple vs apples). In this case, it’s a bit more complicated, but it looks like this:

As you can see, you can change the returned string based on some variable. Please note all variables are strings, so you need to call a standard function like `std::stoi` to obtain an integer.

### Fallbacks[](#fallbacks)

In general, if you are translating into a language with regional variants, if the translations are the same, you don’t need two entries.

Order of fallbacks is as follows:

`xy_ZT` -&gt; `xy_XY` -&gt; `xy_ANYTHING` -&gt; `global fallback`, usually `en_US`.

So, if you write something for `de_DE`, and the user has `de_AT`, if `de_AT` is missing, `de_DE` will be used.