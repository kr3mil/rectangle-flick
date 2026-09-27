# Rectangle Flick

Rectangle Pro-inspired window management for Windows 11. Hold **Ctrl + Left Alt**,
choose a destination with a mouse gesture, and release to snap the focused window.
No click or drag is required.

An independent native Windhawk mod by [kr3mil](https://github.com/kr3mil), inspired
by [Rectangle Pro's Window Throw](https://rectangleapp.com/pro/docs/cursor-movement/).
Not affiliated with Rectangle Pro or its developer. This project recreates the
core interaction rather than its full feature set.

**Version 1.0.0 · MIT license · Windows 11 · Requires Windhawk**

## Install

1. Install [Windhawk](https://windhawk.net/).
2. Open **Create a New Mod** and replace the sample with [mod.wh.cpp](mod.wh.cpp).
3. Press **Compile Mod** (Ctrl+B) with **Enable mod** on.
4. Focus a normal resizable window and try the gesture below.

For updates, replace the source in the existing mod's editor and compile again.
See [CHANGELOG.md](CHANGELOG.md) for release notes and [PUBLISHING.md](PUBLISHING.md)
for submission preparation. The public catalog submission is a separate step.

## Interaction

1. Focus an ordinary resizable application.
2. Hold either Ctrl key and **Left Alt**, in either order.
3. A small translucent red circle stays at the initial cursor position throughout
   the gesture, marking the centre of the direction sectors and safe area.
4. Pause as long as needed, then move at least 50 physical pixels from the starting point.
5. A translucent blue region previews the result. Change direction to change the preview.
6. Release either modifier to apply it. Moving back inside the threshold clears the selection.

Esc, another non-modifier key, clicking, scrolling, or switching focus cancels.
Release and press the chord again after cancellation. Right Alt/AltGr is excluded
so international text entry does not activate the mod. Input is always passed through.
There is no arming timeout. No window movement occurs before release.

| Direction | Result |
| --- | --- |
| Left / right | Corresponding half |
| Up | Maximise (preview uses work area) |
| Down | Centred at 70% of work-area dimensions |
| Four diagonals | Corresponding quarter |

Settings cover distance, diagonal balance, cooldown, cursor restoration and
excluded executable names. The previous timeout setting is no longer used.
The default diagonal ratio of 58% means roughly 30–60 degrees within each quadrant.

## Architecture

One instance per session hosted in Explorer, with no Explorer-internal hooks.
A dedicated thread pumps low-level keyboard and mouse hooks plus foreground-change
events. A second thread owns the indicator and preview windows and applies actions.
Visual updates are coalesced through an event and a short snapshot-copy lock.
Hooks never paint overlays or resize applications. Both threads block when idle.

Overlays use native layered, topmost, tool windows with WS_EX_NOACTIVATE and
WS_EX_TRANSPARENT, so they neither take focus nor intercept clicks. The cursor
indicator is a 24-pixel circle at approximately 49% opacity; the region preview
is blue at approximately 25% opacity. All overlay windows are destroyed before
mod unload, and the custom window class is unregistered.

Per-monitor V2 DPI awareness keeps geometry in physical coordinates. The target
window's monitor work area is used, with DWM visible-frame compensation for hidden
resize borders. Absolute region calculations avoid accumulating rounding errors.
Maximised windows restore asynchronously with a bounded wait. Async positioning
keeps a hung application from blocking the worker indefinitely.

Hidden, minimised, cloaked, child, owned, tool, non-resizable, shell and fullscreen
windows are skipped. Windhawk, Terraria and RuneLite are excluded by default.
Add other windowed games to the exclusions. Eligible apps with custom frames or
minimum sizes may not exactly fill a preview. Elevated applications may reject
positioning from Explorer. Low-level hooks can be silently removed by Windows
if timed out; toggle the mod off/on if gestures stop responding.

## Validation

- `./build.ps1`: installed Windhawk compiler/API/import library (validated on 1.7.3),
  with `-Wall -Wextra -Werror`.
- `./test.ps1`: actual classifier, chord requirements including AltGr rejection,
  all eight directions and angle boundaries, odd/negative work-area geometry,
  native overlay creation, transparency/nonactivation flags, circle shape and cleanup.

Live acceptance testing remains necessary for reticle anchoring, perceived latency,
preview rendering, release-to-apply, mixed DPI and individual applications.
Test waiting several seconds after pressing the chord, changing preview direction,
returning to the dead zone, cancelling with Esc/click/focus change, then releasing.
Test repeated snaps, maximised windows, and disabling/reloading while monitoring.

Thirds, saved-position restore, monitor transfer and configurable mappings are
not included in 1.0.0. Down is not historical restore.

## Build and package

Run `./build.ps1`, `./test.ps1`, or `./prepare-release.ps1` in PowerShell.
The packaging script validates metadata, builds and tests, then generates the
single source file needed for the Windhawk catalog. Build and release output is
ignored by Git. No external libraries beyond the Windhawk toolchain are needed.

## Reporting issues

Include the app name, Windows version, monitor scaling, gesture direction and
whether the issue occurs with a restored or maximised window. Please avoid
including private window titles or documents in screenshots.

## References

- [Rectangle Pro Window Throw: fixed reticle, sectors, safe area and release-to-apply](https://rectangleapp.com/pro/docs/cursor-movement/)
- [Windhawk mod format](https://github.com/ramensoftware/windhawk/wiki/Creating-a-new-mod)
- [Existing window-management mod](https://github.com/ramensoftware/windhawk-mods/blob/main/mods/window-opacity.wh.cpp)
- [Low-level hook threading](https://learn.microsoft.com/en-us/windows/win32/winmsg/lowlevelmouseproc)
- [Window bounds and DPI](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowrect)
- [Layered window transparency and input](https://learn.microsoft.com/en-us/windows/win32/winmsg/window-features)
