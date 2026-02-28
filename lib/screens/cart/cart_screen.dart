import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/controllers/cart_controller.dart';
import '../../app/controllers/product_controller.dart';
import '../../app/models/product_model.dart';
import '../../app/theme/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Text(
            'Cart (${CartController.to.itemCount})',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      body: Obx(() {
        final cc = CartController.to;
        if (cc.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (cc.items.isEmpty) {
          return _EmptyCart();
        }
        return _CartContent();
      }),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),
          const Text('Your cart is empty', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          const Text('Start adding products!', style: AppTextStyles.bodySmall),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }
}

class _CartContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            final cc = CartController.to;
            final items = cc.items.entries.toList();
            return ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.paddingS),
              itemBuilder: (_, i) {
                final entry = items[i];
                // Try to get product from product controller cache
                final pc = Get.find<ProductController>();
                final product = pc.allProducts.cast<Product?>().firstWhere(
                  (p) => p?.id == entry.key,
                  orElse: () => null,
                );

                if (product == null) {
                  return const SizedBox.shrink();
                }
                return _CartItem(product: product, qty: entry.value);
              },
            );
          }),
        ),
        _OrderSummary(),
      ],
    );
  }
}

class _CartItem extends StatelessWidget {
  final Product product;
  final int qty;
  const _CartItem({required this.product, required this.qty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            child: SizedBox(
              width: 70,
              height: 70,
              child: CachedNetworkImage(
                imageUrl: product.image,
                fit: BoxFit.contain,
                placeholder: (_, __) => Container(color: AppColors.scaffoldBg),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: AppTextStyles.priceSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Quantity controls
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Btn(
                      icon: qty == 1 ? Icons.delete_outline : Icons.remove,
                      color: qty == 1
                          ? AppColors.errorColor
                          : AppColors.primary,
                      onTap: () =>
                          CartController.to.updateQuantity(product.id, qty - 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '$qty',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    _Btn(
                      icon: Icons.add,
                      color: AppColors.primary,
                      onTap: () =>
                          CartController.to.updateQuantity(product.id, qty + 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: \$${(product.price * qty).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.priceColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cc = CartController.to;
      final pc = Get.find<ProductController>();
      double subtotal = 0;
      for (final entry in cc.items.entries) {
        final product = pc.allProducts.cast<Product?>().firstWhere(
          (p) => p?.id == entry.key,
          orElse: () => null,
        );
        if (product != null) subtotal += product.price * entry.value;
      }
      const shipping = 5.99;
      final total = subtotal + shipping;

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
        child: Column(
          children: [
            _Row('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 4),
            _Row('Shipping', '\$${shipping.toStringAsFixed(2)}'),
            const Divider(height: 16),
            _Row(
              'Total',
              '\$${total.toStringAsFixed(2)}',
              bold: true,
              valueColor: AppColors.priceColor,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Get.snackbar(
                    'Coming Soon',
                    'Checkout feature is not implemented yet',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primary,
                    colorText: Colors.white,
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                    duration: const Duration(seconds: 3),
                  );
                },
                child: const Text(
                  'Proceed to Checkout',
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _Row(this.label, this.value, {this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: bold ? AppTextStyles.heading3 : AppTextStyles.bodySmall,
        ),
        Text(
          value,
          style: bold
              ? AppTextStyles.heading3.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                )
              : AppTextStyles.bodySmall.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                ),
        ),
      ],
    );
  }
}
