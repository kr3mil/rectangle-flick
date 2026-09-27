# Changelog

## 1.0.0

First public release of Rectangle Flick, an independent Windows 11 Windhawk
mod inspired by Rectangle Pro's Window Throw interaction.

- Hold Ctrl + Left Alt to start, move to preview, and release to apply.
- Fixed translucent red reticle marks the gesture origin.
- Translucent destination preview updates as the direction changes.
- Left/right halves, four quarters, maximise, and centred 70% size.
- Adjustable safe-area distance, diagonal sensitivity, cooldown, cursor return,
  and application exclusions.
- Foreground-window targeting, current-monitor work area, per-monitor DPI
  awareness and invisible-border compensation.
- Escape, clicks, scrolling and foreground changes cancel selection.
- Event-driven input and overlay threads with unload cleanup.

This release formalises the tested local interaction from 0.2.1 with publishing
metadata, expanded documentation, licensing and repeatable release packaging.

## 0.2.1 — Local development

Anchored the red reticle at the gesture origin, matching Rectangle Pro's
documented sector and safe-area interaction.

## 0.2.0 — Local development

Introduced Ctrl+Left Alt, visual previews, an activity indicator, unlimited
arming time and release-to-apply.

## 0.1.0 — Local development

Initial Ctrl-flick implementation with eight directions and native window positioning.
