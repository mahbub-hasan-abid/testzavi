import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fixed 3-tab structure (matches the UI requirement of exactly 2-3 tabs).
// Products are loaded once as a full list and then filtered client-side per
// tab — no per-category network requests, no intermediate spinners on tabs.
// ─────────────────────────────────────────────────────────────────────────────

/// The three fixed tabs shown in the home screen.
enum HomeTab {
  all('All'),
  electronics('Electronics'),
  clothing('Clothing');

  final String label;
  const HomeTab(this.label);

  static List<String> get labels => HomeTab.values.map((t) => t.label).toList();
}

class ProductController extends GetxController {
  static ProductController get to => Get.find();

  final _allProducts = <Product>[].obs;
  final _isLoading = false.obs;
  final searchQuery = ''.obs;

  List<Product> get allProducts => List.unmodifiable(_allProducts);
  bool get isLoading => _isLoading.value;

  List<Product> get searchResults {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return allProducts;
    return _allProducts
        .where(
          (p) =>
              p.title.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q),
        )
        .toList();
  }

  /// Returns products for the given [HomeTab].
  /// When a search query is active it overrides the tab filter.
  List<Product> productsForTab(HomeTab tab) {
    if (searchQuery.value.trim().isNotEmpty) return searchResults;
    switch (tab) {
      case HomeTab.all:
        return allProducts;
      case HomeTab.electronics:
        return _allProducts
            .where((p) => p.category.toLowerCase() == 'electronics')
            .toList();
      case HomeTab.clothing:
        return _allProducts
            .where((p) => p.category.toLowerCase().contains('clothing'))
            .toList();
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    _isLoading.value = true;
    update();
    try {
      // FakeStore only has 20 products. Fetch asc + desc and merge so every
      // tab shows a bigger, richer catalog (~40 cards in "All").
      final first = await ApiService.instance.getAllProducts(sort: 'asc');
      final second = await ApiService.instance.getAllProducts(sort: 'desc');
      // Give the second batch offset IDs so widgets have unique keys.
      final extra = second.map((p) => p.copyWithId(p.id + 100)).toList();
      _allProducts.value = [...first, ...extra];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load products. Pull down to refresh.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE84800),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  /// Called on pull-to-refresh.
  Future<void> onRefresh() => loadAll();
}

// ignore: prefer_void_to_null
void unawaited(Future<void> future) {}
