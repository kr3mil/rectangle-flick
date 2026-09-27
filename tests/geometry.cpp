// Exercise the actual implementation without loading a mod or installing hooks.
#include <windows.h>
#include <cstdio>
#include <cstdlib>
#define Wh_Log(...) ((void)0)
int Wh_GetIntSetting(PCWSTR) { return 0; }
PCWSTR Wh_GetStringSetting(PCWSTR) { return nullptr; }
void Wh_FreeStringSetting(PCWSTR) {}
#include "../mod.wh.cpp"

void Check(bool condition, const char* label) {
    if (!condition) { std::fprintf(stderr, "FAIL: %s\n", label); std::exit(1); }
}
int main() {
    Gesture chord{};
    chord.leftCtrl = true;
    Check(!ChordHeld(chord), "Ctrl alone cannot arm");
    chord.leftAlt = true;
    Check(ChordHeld(chord), "Ctrl plus Left Alt arms");
    chord.leftCtrl = false;
    chord.rightCtrl = true;
    Check(ChordHeld(chord), "Right Ctrl plus Left Alt arms");
    chord.rightAlt = true;
    Check(!ChordHeld(chord), "AltGr cannot arm");
    chord = {};
    chord.leftAlt = true;
    Check(!ChordHeld(chord), "Alt alone cannot arm");
    Check(Classify(-80, 10, 58) == Direction::Left, "shallow left is cardinal");
    Check(Classify(80, -10, 58) == Direction::Right, "shallow right is cardinal");
    Check(Classify(10, -80, 58) == Direction::Up, "near vertical up");
    Check(Classify(-10, 80, 58) == Direction::Down, "near vertical down");
    Check(Classify(-60, -60, 58) == Direction::UpLeft, "up left");
    Check(Classify(60, -60, 58) == Direction::UpRight, "up right");
    Check(Classify(-60, 60, 58) == Direction::DownLeft, "down left");
    Check(Classify(60, 60, 58) == Direction::DownRight, "down right");
    Check(Classify(100, 57, 58) == Direction::Right, "outside diagonal boundary");
    Check(Classify(100, 58, 58) == Direction::DownRight, "on diagonal boundary");
    Check(Classify(100, 58, 80) == Direction::Right, "narrower diagonal sensitivity");
    // Odd sizes, negative coordinates, and taskbars on different edges.
    for (RECT work : {RECT{0,0,1920,1040}, RECT{-1919,-1079,0,-40}, RECT{48,30,2561,1440}}) {
        RECT left = Region(work, Direction::Left), right = Region(work, Direction::Right);
        Check(left.right == right.left && left.left == work.left && right.right == work.right,
              "halves tile exactly without rounding gaps");
        auto tl = Region(work, Direction::UpLeft), tr = Region(work, Direction::UpRight);
        auto bl = Region(work, Direction::DownLeft), br = Region(work, Direction::DownRight);
        Check(tl.right == tr.left && bl.right == br.left && tl.bottom == bl.top && tr.bottom == br.top,
              "quarters meet exactly");
        Check(tl.left == work.left && tl.top == work.top && br.right == work.right && br.bottom == work.bottom,
              "quarters respect work area");
        RECT centre = Region(work, Direction::Down);
        Check(centre.left >= work.left && centre.top >= work.top && centre.right <= work.right && centre.bottom <= work.bottom,
              "centre within work area");
        Check(std::abs((centre.left-work.left)-(work.right-centre.right)) <= 1 &&
              std::abs((centre.top-work.top)-(work.bottom-centre.bottom)) <= 1, "centred to within one pixel");
    }
    modModule = GetModuleHandleW(nullptr);
    HWND circle, preview;
    {
        Overlays overlays;
        Check(overlays.Init(), "native overlay creation");
        circle = overlays.circle;
        preview = overlays.preview;
        DWORD required = WS_EX_LAYERED | WS_EX_TRANSPARENT | WS_EX_NOACTIVATE | WS_EX_TOOLWINDOW;
        Check((GetWindowLongPtrW(circle, GWL_EXSTYLE) & required) == required, "circle is click-through and nonactivating");
        Check((GetWindowLongPtrW(preview, GWL_EXSTYLE) & required) == required, "preview is click-through and nonactivating");
        BYTE alpha = 0;
        DWORD flags = 0;
        Check(GetLayeredWindowAttributes(circle, nullptr, &alpha, &flags) && alpha == 125 && flags == LWA_ALPHA,
              "circle is translucent");
        Check(GetLayeredWindowAttributes(preview, nullptr, &alpha, &flags) && alpha == 65,
              "preview is translucent");
        HRGN shape = CreateRectRgn(0,0,0,0);
        Check(GetWindowRgn(circle, shape) != ERROR && PtInRegion(shape,12,12) && !PtInRegion(shape,0,0),
              "indicator has circular geometry");
        DeleteObject(shape);
        Check(!IsWindowVisible(circle) && !IsWindowVisible(preview), "overlays start hidden");
    }
    Check(!IsWindow(circle) && !IsWindow(preview), "overlay windows destroyed on cleanup");
    std::puts("PASS: modifier chord, eight directions, region geometry, native overlay attributes and cleanup.");
}
