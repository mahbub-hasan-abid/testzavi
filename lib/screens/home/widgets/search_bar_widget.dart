import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to search screen (future enhancement)
        Get.snackbar(
          'Search',
          'Search coming soon!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      },
      child: Container(
        height: AppDimensions.searchBarHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Row(
          children: [
            const SizedBox(width: AppDimensions.paddingM),
            const Icon(Icons.search, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Search in Daraz', style: AppTextStyles.bodySmall),
            ),
            Container(
              width: 36,
              height: AppDimensions.searchBarHeight,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(AppDimensions.radiusM),
                  bottomRight: Radius.circular(AppDimensions.radiusM),
                ),
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
