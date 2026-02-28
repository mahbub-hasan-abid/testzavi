# Daraz Clone — Flutter Assignment

A professional Daraz-style e-commerce app built with Flutter using a **single-scroll architecture**, GetX state management, MVC pattern, and the [FakeStore API](https://fakestoreapi.com/).

---

## 🚀 Run Instructions

```bash
flutter pub get
flutter run
```

Demo credentials (FakeStore API):
- **Username:** `johnd`
- **Password:** `m38rmF$`

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

Horizontal tab-switching is handled by `_HorizontalSwipeDetector` — a custom `StatefulWidget` that wraps the product grid area.

**Key design decision:**  
Rather than using a `PageView` (which would create a *second* scroll axis competing with the vertical `CustomScrollView`), we use a bare `GestureDetector` with `onHorizontalDragEnd`. The logic:

- Track `startX` and `startY` on drag start.
- On drag update, **cancel** tracking if `|dy| > |dx|` — i.e., the gesture is more vertical than horizontal. This lets vertical scrolling win naturally.
- On drag end, read `primaryVelocity`. If it exceeds a threshold (40 px/s), call `onSwipeLeft` or `onSwipeRight` to update the tab index in `HomeScreen`'s local `setState`.

This approach means horizontal gestures are **claimed only when intentionally horizontal** and never fight with vertical scroll.

---

### 2. Who Owns the Vertical Scroll (and Why)

**The single `CustomScrollView` in `HomeScreen` owns all vertical scrolling.**

There is exactly one `ScrollController` (`_scrollController`) and one `CustomScrollView` in the entire screen. All content — the collapsible header, the sticky tab bar, and the product grid — lives inside this one scroll view as slivers:

| Sliver | Widget | Notes |
|---|---|---|
| Collapsible header | `SliverAppBar` | Expands/collapses naturally |
| Sticky tab bar | `SliverPersistentHeader(pinned: true)` | Sticks once header scrolls away |
| Product grid | `SliverToBoxAdapter` → `GridView(physics: NeverScrollableScrollPhysics)` | GridView is **non-scrollable** |

The `GridView` inside the tab content has `physics: NeverScrollableScrollPhysics()` so it never creates a nested scroll context. It uses `shrinkWrap: true` so the outer `CustomScrollView` controls all scroll.

**Why this matters:**  
Switching tabs only swaps the sliver content (via `setState`). The `ScrollController` position is never touched on tab switch, so there is no scroll jump or reset.

---

### 3. Trade-offs and Limitations

| Trade-off | Explanation |
|---|---|
| `shrinkWrap: true` on GridView | Causes the entire product list to be laid out eagerly (no lazy loading). Fine for FakeStore's ~20 products. For 1000+ products, use `SliverGrid` instead. |
| Tab content is not animated | Switching tabs has no slide animation since we avoid `PageView`. A custom `AnimatedSwitcher` with a horizontal clip could add polish. |
| No true lazy loading per tab | All tab products are fetched upfront. Could be optimized to fetch only the visible tab on demand. |
| FakeStore token contains no user ID | We hardcode `userId = 1` after login since FakeStore's JWT doesn't expose the user ID in a standard way without a JWT decoder. In a real app, decode the JWT or call `/users/me`. |
| Pull-to-refresh reloads ALL tabs | Since there's one scroll view, one `RefreshIndicator` serves all tabs, which reloads everything. This is correct behavior here. |

---

## ✅ Features

- [x] Login with session persistence (`SharedPreferences`)
- [x] Collapsible header with search bar and banner
- [x] Sticky tab bar (pinned with `SliverPersistentHeader`)
- [x] 2–N tabs from API categories (dynamic)
- [x] **Single vertical scroll** — no nested scrolling conflicts
- [x] Pull-to-refresh on any tab
- [x] Tab switching does NOT reset scroll position
- [x] Horizontal swipe to switch tabs (no vertical scroll interference)
- [x] Product grid from FakeStore API
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


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# testzavi
