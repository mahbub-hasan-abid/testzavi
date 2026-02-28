# Daraz Clone — Flutter Assignment

A professional Daraz-style e-commerce app built with Flutter using a **single-scroll architecture**, GetX state management, MVC pattern, and the [FakeStore API](https://fakestoreapi.com/).

---

## 🚀 Run Instructions

```bash
flutter pub get
flutter run
```

Demo credentials (FakeStore API):
- **Username:** `johnd` / **Password:** `m38rmF$`
- **Username:** `mor_2314` / **Password:** `83r5^_`

Or tap **"Tap to fill"** on the login screen.

---

## 🏗️ Architecture

### Pattern: MVC + GetX

```
lib/
├── app/
│   ├── controllers/       # GetX controllers (state + business logic)
│   │   ├── auth_controller.dart
│   │   ├── product_controller.dart
│   │   └── cart_controller.dart
│   ├── models/            # Pure data models
│   │   ├── product_model.dart
│   │   ├── user_model.dart
│   │   └── cart_model.dart
│   ├── services/          # API layer (http calls only)
│   │   └── api_service.dart
│   ├── routes/            # GetX routing
│   │   ├── app_routes.dart
│   │   └── app_pages.dart
│   └── theme/             # Centralized theme
│       └── app_theme.dart
├── screens/               # UI (Views)
│   ├── login/
│   ├── home/
│   │   └── widgets/
│   ├── product_detail/
│   ├── cart/
│   └── profile/
└── main.dart
```

---

## 📜 Mandatory Explanation

### 1. How Horizontal Swipe Was Implemented

Horizontal tab-switching uses a **`Listener`** widget wrapping the entire `Scaffold` body — intentionally chosen over `GestureDetector`.

**Why `Listener` instead of `GestureDetector`?**

`GestureDetector` participates in Flutter's gesture arena: it competes with the `CustomScrollView`'s scroll recognizer for ownership of each pointer sequence. If the scroll view wins the arena, the `GestureDetector` never fires — horizontal swipes that start with even a slight vertical component get claimed by the scroll view and are silently dropped.

`Listener` is **pre-arena** — it receives every raw `PointerEvent` unconditionally, before arena resolution. This means our swipe detector always sees every finger movement regardless of who wins the arena.

**Logic (in `_HomeScreenState`):**

```
onPointerDown  → record start position, reset flags
onPointerMove  → compute dx / dy from start:
                  • if dy > dx AND dy > 10px → cancel (vertical gesture, let scroll win)
                  • if dx ≥ 20px AND dx > dy/0.6 → lock in as horizontal swipe
onPointerUp    → if locked:
                  • confirm total displacement is still more horizontal than vertical
                  • totalDx < 0 → next tab;  totalDx > 0 → previous tab
```

This means:
- A purely vertical scroll is **never interrupted** — the cancel flag fires at the first hint of vertical dominance.
- A clearly horizontal swipe always fires — even if the scroll view is also scrolling.
- **No gesture arena conflict** — the `Listener` never claims or competes for pointer ownership.

---

### 2. Who Owns the Vertical Scroll (and Why)

**The single `CustomScrollView` in `HomeScreen` owns all vertical scrolling.**

There is exactly one `ScrollController` (`_scrollController`) and one `CustomScrollView` in the entire screen. All content lives inside this one scroll view as slivers:

| Sliver | Widget | Notes |
|---|---|---|
| Collapsible header | `SliverAppBar(floating, snap)` | Fully collapses on scroll, snaps back on pull |
| Sticky tab bar | `SliverPersistentHeader(pinned: true)` | Sticks at top once header scrolls away |
| Product grid | `SliverGrid` | Native sliver — no `shrinkWrap`, no nested scroll |

**Why `SliverGrid` instead of `GridView(shrinkWrap: true)`?**

`GridView(shrinkWrap: true, physics: NeverScrollableScrollPhysics)` forces the entire product list to lay out eagerly and creates a nested scroll context (even with `NeverScrollable`). `SliverGrid` is a first-class citizen of the `CustomScrollView` — it lays out lazily, has no scroll context of its own, and never conflicts.

**Why tab switching doesn't jump scroll position:**

Switching tabs calls `setState(() => _activeTab = newTab)`. This rebuilds only the `Obx` that wraps `_ProductGrid` — it replaces the sliver's child delegate. The `ScrollController` position is never read or written on tab change. The scroll view itself does not remount.

---

### 3. Trade-offs and Limitations

| Trade-off | Explanation |
|---|---|
| `Listener` sees all pointer events | The swipe detection logic in `onPointerMove` runs on every frame while a finger is down. It is O(1) and trivially fast, but it is more code than a simple `GestureDetector.onHorizontalDragEnd`. |
| No swipe animation | Switching tabs has no slide animation — we deliberately avoid `PageView` since it would introduce a second scroll axis. An `AnimatedSwitcher` with a directional clip could add polish without conflict. |
| Client-side tab filtering | All ~40 products are fetched once (asc + desc from FakeStore) and filtered in-memory per tab. For a real app with thousands of SKUs per category, you'd paginate per-tab with separate API calls. |
| FakeStore JWT has no user ID | FakeStore's login returns a token but the JWT payload doesn't expose `userId` in a standard claim. We hardcode `userId = 1` for cart API calls. In a real app, decode the JWT or call `/users/me`. |
| Pull-to-refresh reloads all tabs | One `RefreshIndicator` on the single scroll view reloads the entire product list. This is correct and intentional — there is no per-tab independent data. |
| `floating + snap` header | The header uses `pinned: false, floating: true, snap: true` so it fully disappears on scroll but snaps back instantly on pull. The tab bar accounts for safe-area height via `overlapsContent` so tabs are always tappable below the status bar. |

---

## ✅ Features

- [x] Login with session persistence (`SharedPreferences`)
- [x] Collapsible header with search bar and auto-advancing banner
- [x] Sticky tab bar (pinned with `SliverPersistentHeader`)
- [x] 3 tabs: All / Electronics / Clothing
- [x] **Single vertical scroll** — no nested scrolling conflicts
- [x] **`SliverGrid`** — lazy, no shrinkWrap, no nested scroll context
- [x] Pull-to-refresh on any tab
- [x] Tab switching does NOT reset scroll position
- [x] Horizontal swipe via `Listener` — never conflicts with vertical scroll
- [x] Live product search across all tabs
- [x] Product detail screen
- [x] Cart with add/update/delete (synced to API)
- [x] User profile from FakeStore API
- [x] Logout with session cleanup
- [x] Shimmer loading placeholders
- [x] Daraz color theme centralized in `app_theme.dart`

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `get` | State management, routing, dependency injection |
| `http` | API calls |
| `shared_preferences` | Persist login session |
| `cached_network_image` | Efficient image loading with caching |
| `flutter_rating_bar` | Star rating display |
| `shimmer` | Loading skeleton UI |
