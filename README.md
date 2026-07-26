# Fortune Wheel Demo — Project Overview

Repo: https://github.com/mohammad-elahii/Fortune-wheel-demo
Stack: Flutter (Dart), multi-platform (Android, iOS, Web, Windows, Linux, macOS)
Client: Built as a demo for a company called "Rectazone"; final version pending their approval.

This document is meant to bring a human or another AI up to speed quickly: what the app does, how it's structured, and what conventions to follow when touching the code.

---

## 1. What the app does (features)

A single-screen "spin the wheel" prize game:

- Fortune wheel — a circular wheel with 6 prize segments (via the flutter_fortune_wheel package), spinnable either by tapping SPIN or by dragging (CircularPanPhysics).
- Ticket-gated spins — the user starts with 2 tickets; each spin consumes one. The SPIN button disables itself (shows "...") when tickets run out or a spin is in progress.
- Randomized outcome — winning segment is chosen with Fortune.randomInt, purely client-side/random (not yet server-driven).
- Slide-up wheel animation — the wheel lives off-screen at the bottom and animates upward (AnimationController + CurvedAnimation) when a spin starts, while the top content fades out. It slides back down after the spin ends.
- Result dialog — on landing, shows a modal with the prize icon/name ("You won!" or "unlucky!" for the "Try Again" segment), a Share button (native share sheet via share_plus, pre-filled with a promo message + link), and an OK button that resets state.
- Account dropdown — toggled from a top-right icon button; shows mock profile info (name, phone, ticket count, list of previously won prizes).
- Decorative animated grid background — an 8×8 grid behind the top UI where one random tile lights up in a random color every 300ms (pure visual flourish, Timer.periodic).
- Theming — dark theme, Poppins/Google Fonts, a small fixed color palette.

### Known gaps (explicitly noted in code / structure)
- All data is mock/hardcoded (prize list, user profile) — comment in prize_data.dart notes prizes will come from a server later.
- No authentication yet — main.dart comment notes the wheel is the home screen "for now before adding oAuth."
- Layout has known non-responsiveness issues (icon button sizing, wheel sizing in landscape) — flagged directly in code comments.
- No backend/networking, no persistence — everything resets when the app restarts.

---

## 2. Architecture / file structure

lib/
├── main.dart          # App entry point, MaterialApp setup, theme wiring
├── wheel.dart          # Main screen: state machine for spin flow, layout, animation
├── components.dart     # Reusable widgets: textWithStyle, iconButton, AccountDropdown, SpinButton
├── prize_data.dart     # Data models (PrizeData, ProfileData) + hardcoded prize list
├── result_dialog.dart  # showResultDialog() — the post-spin modal
├── animated_grid.dart  # SpinnerAnimatedGrid — decorative background widget
└── theme.dart          # Shared color constants

Pattern used: plain StatefulWidget + setState, no external state management (no Provider/Riverpod/Bloc). This is appropriate for the current scope (single screen, no persistence, no async data). If the app grows (auth, server-fetched prizes, multiple screens), this will need a real state-management layer — worth flagging as a deliberate current-vs-future tradeoff rather than an oversight.

Data flow for a spin (in wheel.dart):
1. User taps SPIN → _spin() decrements ticket, triggers _wheelCtrl.forward() (slide-up animation).
2. On animation complete → a random prize index is picked and pushed into selectedController (a StreamController<int>), which the FortuneWheel widget listens to via its selected stream to know where to land.
3. FortuneWheel's own spin animation runs, then calls back _onSpinEnd().
4. _onSpinEnd() waits briefly, slides the wheel back down, then shows the result dialog.
5. Dialog OK button calls _reset() to return to idle state.