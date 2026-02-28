import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import '../../../app/models/product_model.dart';
import '../../../app/controllers/cart_controller.dart';
import '../../../app/theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusM),
                topRight: Radius.circular(AppDimensions.radiusM),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => Container(
                    color: AppColors.scaffoldBg,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.scaffoldBg,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),
            ),

            // Info section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Title — takes remaining space, clips if needed
                    Expanded(
                      child: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
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
                          itemSize: 11,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.rating.count})',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Price row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: AppTextStyles.priceSmall,
                              ),
                              Text(
                                '\$${product.originalPrice.toStringAsFixed(2)}',
                                style: AppTextStyles.originalPrice,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '-${product.discountPercent}%',
                          style: AppTextStyles.discount,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Add to cart button
                    Obx(() {
                      final qty = CartController.to.quantityOf(product.id);
                      if (qty > 0) {
                        return _QtyControl(product: product, qty: qty);
                      }
                      return _AddToCartButton(product: product);
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final Product product;
  const _AddToCartButton({required this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => CartController.to.addToCart(product),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
        ),
        child: const Text(
          'Add to Cart',
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final Product product;
  final int qty;
  const _QtyControl({required this.product, required this.qty});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ControlBtn(
            icon: qty == 1 ? Icons.delete_outline : Icons.remove,
            color: qty == 1 ? AppColors.errorColor : AppColors.primary,
            onTap: () => CartController.to.updateQuantity(product.id, qty - 1),
          ),
          Text(
            '$qty',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
          _ControlBtn(
            icon: Icons.add,
            color: AppColors.primary,
            onTap: () => CartController.to.updateQuantity(product.id, qty + 1),
          ),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ControlBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
