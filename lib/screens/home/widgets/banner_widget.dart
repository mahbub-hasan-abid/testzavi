import 'dart:async';
import 'package:flutter/material.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});
  static const double height = 120.0;

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  static const _banners = [
    _BannerData(
      emoji: '🛍️',
      tag: 'MEGA SALE',
      title: 'Up to 70% OFF',
      subtitle: 'On Electronics & Gadgets',
      gradientStart: Color(0xFFE84800),
      gradientEnd: Color(0xFFFF6F00),
    ),
    _BannerData(
      emoji: '🚚',
      tag: 'FREE DELIVERY',
      title: 'Shop & Save More',
      subtitle: 'Free shipping on orders above \$50',
      gradientStart: Color(0xFF1565C0),
      gradientEnd: Color(0xFF1976D2),
    ),
    _BannerData(
      emoji: '⚡',
      tag: 'FLASH DEAL',
      title: 'Limited Time Offer',
      subtitle: 'New arrivals — grab them fast!',
      gradientStart: Color(0xFF2E7D32),
      gradientEnd: Color(0xFF388E3C),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % _banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: BannerWidget.height,
      child: Stack(
        children: [
          // ── Carousel ───────────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _banners.length,
            itemBuilder: (_, i) => _BannerCard(banner: _banners[i]),
          ),

          // ── Dot indicator (bottom-centre) ──────────────────────────────
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_banners.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: active ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final _BannerData banner;
  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [banner.gradientStart, banner.gradientEnd],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // ── Left: text content ─────────────────────────────────────────
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    banner.tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  banner.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  banner.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Shop Now',
                    style: TextStyle(
                      color: banner.gradientStart,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Right: emoji icon ──────────────────────────────────────────
          Text(banner.emoji, style: const TextStyle(fontSize: 56)),
        ],
      ),
    );
  }
}

class _BannerData {
  final String emoji;
  final String tag;
  final String title;
  final String subtitle;
  final Color gradientStart;
  final Color gradientEnd;

  const _BannerData({
    required this.emoji,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.gradientStart,
    required this.gradientEnd,
  });
}
