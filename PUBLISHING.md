# Publishing Rectangle Flick

## Release preparation

1. Set `@github` in `mod.wh.cpp` to the GitHub account that will submit the mod.
2. Run `./prepare-release.ps1`. Use `-WindhawkPath` for a different installation.
3. The script compiles against the installed Windhawk engine, runs the tests,
   validates release metadata, and produces
   `release/rectangle-flick-1.0.0/mods/rectangle-flick.wh.cpp` plus a SHA-256 checksum.

The source is the release artifact. Users compile it through Windhawk; no
precompiled DLL needs to be distributed. `mod.wh.cpp` remains the canonical source.

## Submit to the Windhawk collection

Fork [ramensoftware/windhawk-mods](https://github.com/ramensoftware/windhawk-mods).
Add the prepared file at `mods/rectangle-flick.wh.cpp` and submit a pull request.
Include **only that one file**. Its `@github` value must match the submitting
account. Do not add this project's build scripts, tests, docs or DLL to that PR.

Suggested PR title: **Add Rectangle Flick 1.0.0**

Suggested description:

> Adds Rectangle Flick, an independent Windows 11 mod inspired by Rectangle
> Pro's Window Throw interaction. Hold Ctrl+Left Alt to display a fixed red
> reticle, move the cursor to preview a half, quarter, maximised or centred
> region, and release to apply it to the foreground window.
>
> Uses documented Win32 input hooks and layered overlays in Explorer, with
> separate input and action threads. Includes adjustable gesture sensitivity,
> application exclusions and cleanup on unload.
>
> Validation: compiled with the installed Windhawk 1.7.3 toolchain with warnings
> treated as errors. Automated checks cover chord detection, direction and region
> geometry, overlay attributes and cleanup. Local user testing confirmed the
> core interaction. Exhaustive mixed-DPI and application compatibility testing
> has not been performed.

Before submission, smoke-test the packaged version in Windhawk: activation,
preview, release, cancellation, settings reload and disable/re-enable. Test
multiple DPI scales if available; document any limits rather than claiming
unverified coverage. The user has tested the local interaction, but these checks
have not all been independently observed by the developer automation.

Publication has not been performed by the preparation script.

Requirements checked against the
[official contribution instructions](https://github.com/ramensoftware/windhawk-mods#submitting-a-new-mod).
