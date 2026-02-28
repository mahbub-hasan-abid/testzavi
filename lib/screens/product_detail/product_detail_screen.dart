import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../app/models/product_model.dart';
import '../../app/controllers/cart_controller.dart';
import '../../app/theme/app_theme.dart';
import '../../app/routes/app_routes.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final product = Get.arguments as Product;
    final cc = CartController.to;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Product Detail',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          Obx(
            () => Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () => Get.toNamed(AppRoutes.cart),
                ),
                if (cc.itemCount > 0)
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
                          '${cc.itemCount}',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              color: Colors.white,
              height: 300,
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: CachedNetworkImage(
                imageUrl: product.image,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 60),
              ),
            ),
            const Divider(height: 1),

            // Info
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tagBg,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(product.title, style: AppTextStyles.heading2),
                  const SizedBox(height: 12),

                  // Rating
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: product.rating.rate,
                        itemBuilder: (_, __) => const Icon(
                          Icons.star,
                          color: AppColors.ratingColor,
                        ),
                        itemCount: 5,
                        itemSize: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${product.rating.rate} (${product.rating.count} reviews)',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: AppTextStyles.price.copyWith(fontSize: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '\$${product.originalPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.originalPrice.copyWith(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.discountColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: AppTextStyles.discount.copyWith(
                            color: AppColors.discountColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Description', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // Bottom add to cart bar
      bottomNavigationBar: _BottomBar(product: product),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final Product product;
  const _BottomBar({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        final cc = CartController.to;
        final qty = cc.quantityOf(product.id);

        return Row(
          children: [
            if (qty > 0) ...[
              // Quantity controller
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        qty == 1 ? Icons.delete_outline : Icons.remove,
                        color: qty == 1
                            ? AppColors.errorColor
                            : AppColors.primary,
                        size: 20,
                      ),
                      onPressed: () => cc.updateQuantity(product.id, qty - 1),
                    ),
                    Text(
                      '$qty',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onPressed: () => cc.updateQuantity(product.id, qty + 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: qty > 0
                      ? () => Get.toNamed(AppRoutes.cart)
                      : () => cc.addToCart(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: qty > 0
                        ? AppColors.primaryDark
                        : AppColors.primary,
                  ),
                  child: Text(
                    qty > 0 ? 'Go to Cart' : 'Add to Cart',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
