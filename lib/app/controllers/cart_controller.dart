import 'package:get/get.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';

/// Owns cart state. Fetches from API and reflects updates back to API.
///
/// The local [_items] map (productId → qty) acts as the working copy.
/// Every mutation is immediately sent to the API and the local state is
/// updated optimistically so the UI feels snappy.
class CartController extends GetxController {
  static CartController get to => Get.find();

  // productId → quantity (local working copy)
  final _items = <int, int>{}.obs;
  final _products = <int, Product>{}.obs; // cache for product details
  final _isLoading = false.obs;
  int? _remoteCartId; // ID of the cart on the server

  Map<int, int> get items => _items;
  bool get isLoading => _isLoading.value;
  int get itemCount => _items.values.fold(0, (a, b) => a + b);

  double get subtotal {
    double total = 0;
    for (final entry in _items.entries) {
      final product = _products[entry.key];
      if (product != null) total += product.price * entry.value;
    }
    return total;
  }

  List<Product> get cartProducts =>
      _products.values.where((p) => _items.containsKey(p.id)).toList();

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  Future<void> loadCart() async {
    _isLoading.value = true;
    try {
      final userId = AuthController.to.userId;
      if (userId <= 0) return;

      final carts = await ApiService.instance.getUserCarts(userId);
      if (carts.isNotEmpty) {
        final cart = carts.first;
        _remoteCartId = cart.id;

        _items.clear();
        for (final cp in cart.products) {
          _items[cp.productId] = cp.quantity;
        }

        // fetch product details for each cart item
        await _fetchProductDetails();
      }
    } catch (_) {
      // non-fatal – cart stays empty
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _fetchProductDetails() async {
    for (final id in _items.keys) {
      if (!_products.containsKey(id)) {
        try {
          final p = await ApiService.instance.getProduct(id);
          _products[id] = p;
        } catch (_) {}
      }
    }
  }

  Future<void> addToCart(Product product) async {
    final prev = _items[product.id] ?? 0;
    _items[product.id] = prev + 1;
    _products[product.id] = product;
    await _syncCart();
    Get.snackbar(
      'Added',
      '${product.title} added to cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> updateQuantity(int productId, int qty) async {
    if (qty <= 0) {
      _items.remove(productId);
    } else {
      _items[productId] = qty;
    }
    await _syncCart();
  }

  Future<void> removeFromCart(int productId) async {
    _items.remove(productId);
    await _syncCart();
  }

  Future<void> clearCart() async {
    if (_remoteCartId != null) {
      try {
        await ApiService.instance.deleteCart(_remoteCartId!);
      } catch (_) {}
    }
    _items.clear();
    _remoteCartId = null;
  }

  Future<void> _syncCart() async {
    try {
      final userId = AuthController.to.userId;
      if (userId <= 0) return;

      final cartProducts = _items.entries
          .map((e) => CartProduct(productId: e.key, quantity: e.value))
          .toList();

      if (_remoteCartId != null) {
        await ApiService.instance.updateCart(
          cartId: _remoteCartId!,
          userId: userId,
          products: cartProducts,
        );
      } else {
        final newCart = await ApiService.instance.addCart(
          userId: userId,
          products: cartProducts,
        );
        _remoteCartId = newCart.id;
      }
    } catch (_) {
      // Local state already updated; API failure is non-critical here
    }
  }

  int quantityOf(int productId) => _items[productId] ?? 0;
  bool isInCart(int productId) => _items.containsKey(productId);
}
