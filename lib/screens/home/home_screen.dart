import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/product_controller.dart';
import '../../app/controllers/cart_controller.dart';
import '../../app/theme/app_theme.dart';
import '../../app/routes/app_routes.dart';
import '../../app/models/product_model.dart';
import 'widgets/product_card.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/banner_widget.dart';
import 'widgets/shimmer_product_grid.dart';

// ═════════════════════════════════════════════════════════════════════════════
// HOME SCREEN — SINGLE-SCROLLER ARCHITECTURE
// ═════════════════════════════════════════════════════════════════════════════
//
//  ONE CustomScrollView  →  one ScrollController  →  no nested scrollables.
//
//  Sliver order:
//    1. SliverAppBar (collapsible header: logo + search + cart + banner)
//    2. SliverPersistentHeader(pinned:true)  ← sticky 3-tab bar
//    3. SliverToBoxAdapter  ← product grid for the active tab (NeverScrollable)
//
//  Tab switching:
//    • Changes only which product list is rendered inside sliver 3.
//    • Does NOT touch the ScrollController → no position jump.
//
//  Pull-to-refresh:
//    • RefreshIndicator wraps the CustomScrollView → works from any tab.
//
//  Scrollbar:
//    • Scrollbar widget wraps CustomScrollView → always-visible thumb.
//
// ═════════════════════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: true,
  );

  HomeTab _activeTab = HomeTab.all;

  // ── Swipe tracking via Listener (pointer events, pre-arena) ──────────────
  // We use Listener instead of GestureDetector so we NEVER enter the gesture
  // arena and NEVER compete with the CustomScrollView's scroll recognizer.
  // Listener fires for every raw pointer event regardless of who wins the arena.
  Offset? _pointerDown;    // position at finger-down
  Offset? _pointerCurrent; // latest finger position
  bool _swipeLocked = false; // true once we've committed to horizontal
  bool _swipeCancelled = false; // true if motion became too vertical

  static const double _minHorizontalPx = 20.0; // min horizontal travel
  static const double _maxVerticalRatio = 0.6;  // dy/dx must stay below this

  void _switchTab(HomeTab tab) {
    if (_activeTab == tab) return;
    setState(() => _activeTab = tab);
  }

  void _onPointerDown(PointerDownEvent e) {
    _pointerDown = e.position;
    _pointerCurrent = e.position;
    _swipeLocked = false;
    _swipeCancelled = false;
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_swipeCancelled || _pointerDown == null) return;
    _pointerCurrent = e.position;
    final dx = (e.position.dx - _pointerDown!.dx).abs();
    final dy = (e.position.dy - _pointerDown!.dy).abs();
    if (!_swipeLocked) {
      // Cancel if vertical motion dominates before we lock horizontal.
      if (dy > dx && dy > 10) {
        _swipeCancelled = true;
        return;
      }
      // Lock in as horizontal swipe once we have enough horizontal travel.
      if (dx >= _minHorizontalPx && dx > dy / _maxVerticalRatio) {
        _swipeLocked = true;
      }
    }
  }

  void _onPointerUp(PointerUpEvent e) {
    if (!_swipeLocked || _pointerDown == null) {
      _pointerDown = null;
      return;
    }
    final totalDx = e.position.dx - _pointerDown!.dx;
    final totalDy = (e.position.dy - _pointerDown!.dy).abs();
    _pointerDown = null;
    _swipeLocked = false;

    // Confirm the overall gesture is still more horizontal than vertical.
    if (totalDy > totalDx.abs() * 0.8) return;
    // Require a minimum travel distance.
    if (totalDx.abs() < _minHorizontalPx) return;

    if (totalDx < 0) {
      // swiped left → advance to next tab
      final next = HomeTab.values.indexOf(_activeTab) + 1;
      if (next < HomeTab.values.length) _switchTab(HomeTab.values[next]);
    } else {
      // swiped right → go to previous tab
      final prev = HomeTab.values.indexOf(_activeTab) - 1;
      if (prev >= 0) _switchTab(HomeTab.values[prev]);
    }
  }

  void _onPointerCancel(PointerCancelEvent e) {
    _pointerDown = null;
    _swipeLocked = false;
    _swipeCancelled = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Listener(
        // Listener is PRE-arena — it always receives raw pointer events
        // even when the CustomScrollView has won the gesture arena.
        // This means swipe detection never conflicts with vertical scroll.
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ProductController.to.onRefresh(),
          child: RawScrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 6,
            radius: const Radius.circular(6),
            thumbColor: AppColors.primary,
            trackColor: AppColors.primary.withValues(alpha: 0.12),
            trackBorderColor: Colors.transparent,
            child: CustomScrollView(
              key: const PageStorageKey<String>('home_scroll'),
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // ── 1. Collapsible header ────────────────────────────────
                _CollapsibleHeader(cartController: CartController.to),

                // ── 2. Sticky 3-tab bar ──────────────────────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    activeTab: _activeTab,
                    onTabSelected: _switchTab,
                  ),
                ),

                // ── 3. Product grid — GetBuilder wraps only this sliver ──
                GetBuilder<ProductController>(
                  builder: (pc) {
                    if (pc.isLoading) {
                      return const SliverPadding(
                        padding: EdgeInsets.all(AppDimensions.paddingS),
                        sliver: ShimmerProductGrid(),
                      );
                    }
                    return _ProductGrid(
                      products: pc.productsForTab(_activeTab),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Collapsible header (SliverAppBar)
// ─────────────────────────────────────────────────────────────────────────────

class _CollapsibleHeader extends StatelessWidget {
  final CartController cartController;
  const _CollapsibleHeader({required this.cartController});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    // expandedHeight = status bar + top-bar (56) + banner (50)
    // Must exactly match the actual rendered heights or the tab bar
    // will be clipped / unreachable after the header collapses.
    final expandedHeight = topPad + 56.0 + 50.0;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      // toolbarHeight = status bar + top-bar row so the logo/search/cart
      // remain pinned to the top after the banner collapses.
      toolbarHeight: topPad + 56.0,
      floating: false,
      pinned: true, // keeps the top bar visible — tab bar is never hidden
      snap: false,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Column(
          children: [
            SizedBox(height: topPad),
            // ── Top bar: logo · search · cart · profile ──────────────────
            Container(
              height: 56,
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
              ),
              child: Row(
                children: [
                  // Logo
                  const Text(
                    'Daraz',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Search bar (expanded)
                  const Expanded(child: SearchBarWidget()),
                  const SizedBox(width: 4),
                  // Cart icon with badge
                  Obx(() => _CartIconButton(count: cartController.itemCount)),
                  // Profile
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Colors.white),
                    onPressed: () => Get.toNamed(AppRoutes.profile),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ],
              ),
            ),
            // ── Promo banner (collapsible part) ─────────────────────────
            const BannerWidget(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Sticky 3-tab bar delegate
// ─────────────────────────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final HomeTab activeTab;
  final ValueChanged<HomeTab> onTabSelected;

  const _TabBarDelegate({required this.activeTab, required this.onTabSelected});

  static const double _height = 48.0;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Colors.white,
      elevation: overlapsContent ? 4 : 0,
      shadowColor: Colors.black26,
      child: Column(
        children: [
          SizedBox(
            height: _height - 1,
            child: Row(
              children: HomeTab.values.map((tab) {
                final selected = tab == activeTab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTabSelected(tab),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => old.activeTab != activeTab;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Product grid sliver
//    Returns a sliver — either SliverFillRemaining (empty) or
//    SliverPadding > SliverGrid (with products).
//    Swipe is handled at Scaffold level (see _HomeScreenState) so NO
//    GestureDetector lives here — zero gesture arena conflict.
// ─────────────────────────────────────────────────────────────────────────────

class _ProductGrid extends StatelessWidget {
  final List<Product> products;
  const _ProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'No products found',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    final cols = MediaQuery.of(context).size.width > 600 ? 3 : 2;
    return SliverPadding(
      padding: const EdgeInsets.all(AppDimensions.paddingS),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => ProductCard(
            product: products[i],
            onTap: () =>
                Get.toNamed(AppRoutes.productDetail, arguments: products[i]),
          ),
          childCount: products.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          childAspectRatio: 0.58,
          crossAxisSpacing: AppDimensions.paddingS,
          mainAxisSpacing: AppDimensions.paddingS,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cart icon with badge
// ─────────────────────────────────────────────────────────────────────────────

class _CartIconButton extends StatelessWidget {
  final int count;
  const _CartIconButton({required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          onPressed: () => Get.toNamed(AppRoutes.cart),
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom navigation bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) Get.toNamed(AppRoutes.cart);
          if (i == 2) Get.toNamed(AppRoutes.profile);
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Obx(() {
              final count = CartController.to.itemCount;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined),
                  if (count > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCROLL ARCHITECTURE EXPLANATION
// ─────────────────────────────────────────────────────────────────────────────
//
// SINGLE SCROLL OWNER:
//   There is exactly ONE ScrollController driving ONE CustomScrollView.
//   All content (header, tab bar, product grids) lives inside that single
//   CustomScrollView as slivers. This eliminates all nested-scroll conflicts.
//
// HOW TABS WORK:
//   - Tab content is NOT a separate scrollable widget.
//   - Each "tab" is a SliverList that is shown/hidden based on the selected
//     tab index via an Obx rebuild inside a single SliverMainAxisGroup.
//   - Switching tabs replaces the sliver content in place — the outer
//     ScrollController position is preserved and never reset.
//
// HORIZONTAL SWIPE:
//   A GestureDetector with HitTestBehavior.deferToChild wraps the sliver
//   content area. Horizontal drags are consumed locally to switch tabs
//   while vertical drags are ignored (fall through to the ScrollView).
//   This prevents horizontal gestures from participating in vertical scroll.
//
// PULL-TO-REFRESH:
//   A single SliverRefreshControl (via RefreshIndicator wrapper on the
//   CustomScrollView) handles pull-to-refresh for all tabs since there is
//   only one scroll view.
//
// TAB BAR PINNING:
//   A SliverPersistentHeader with pinned: true holds the tab bar.
//   It stays on screen once the collapsible header scrolls away.
//
// ─────────────────────────────────────────────────────────────────────────────
