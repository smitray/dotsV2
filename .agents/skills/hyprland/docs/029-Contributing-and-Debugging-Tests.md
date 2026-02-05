---
title: Tests
url: https://wiki.hypr.land/Contributing-and-Debugging/Tests/
source: sitemap
fetched_at: 2026-02-01T09:23:35.884403658-03:00
rendered_js: false
word_count: 284
summary: This document explains how testing works within hypr* projects, covering both unit tests (GTests) and integration tests (hyprtester) used to ensure code quality and prevent regressions.
tags:
    - testing
    - unit-testing
    - integration-testing
    - hyprland
    - gtests
    - hyprtester
    - debug-build
category: guide
---

Hyprland and some other projects under the hypr* umbrella have *tests* that try to catch bugs and regressions before code is merged.

Building in Debug will by default build tests.

## Running tests[](#running-tests)

### GTests[](#gtests)

GTests are GoogleTests that are *unit tests*. These tests simply check how some elements behave when they can run on their own.

In all hypr* projects, GTests are ran by ctest. Run:

And make sure your tests pass.

### Hyprland’s hyprtester[](#hyprlands-hyprtester)

A lot of hyprland’s code cannot be unit tested, thus we have our own Hyprtester binary which runs hyprland and issues commands and expects results.

To run Hyprtester, `cd` into `./hyprtester`, then run:

*This will run for a while!* At the end, it will print summary results of how many tests passed, and how many failed.

The goal of failed tests is to be **0**.

## Submitting new tests[](#submitting-new-tests)

New tests have to either be a GTest, if the thing tested is possible to be unit tested, or a part of hyprtester.

For both test types, you can check the test directories in the project. GTests live in `tests/`, while hyprtester tests live in `hyprtester/`.

### What to test[](#what-to-test)

If you’re submitting a new feature, it’s obviously your feature. For a fix, try to write a test case that would fail before your fix.

For new tests, you can inspect the coverage report.

First, run *both* ctest and hyprtester. Then, run (from the repo root):

this will run for a while, then open a report in your browser. You can see which files have been tested in what amount, and click on the files to see a line-by-line breakdown.

If there are paths untested, we’d be very happy to receive tests for them.