import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _banners = const [
    _BannerData._(
      '🛍️',
      'Super Sale',
      'Up to 70% OFF on Electronics',
      AppColors.primary,
    ),
    _BannerData._(
      '📦',
      'Free Shipping',
      'On orders above \$50',
      Color(0xFF1565C0),
    ),
    _BannerData._('⭐', 'Flash Deals', 'Limited time offers', Color(0xFF2E7D32)),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: AppColors.primaryDark,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _banners.length,
            itemBuilder: (_, i) {
              final b = _banners[i];
              return Container(
                color: b.color.withValues(alpha: 0.9),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Row(
                  children: [
                    Text(b.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          b.subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          // Dots
          Positioned(
            right: 8,
            bottom: 6,
            child: Row(
              children: List.generate(_banners.length, (i) {
                return Container(
                  width: _currentPage == i ? 16 : 6,
                  height: 4,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color: _currentPage == i ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(2),
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

class _BannerData {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  const _BannerData._(this.emoji, this.title, this.subtitle, this.color);
}
