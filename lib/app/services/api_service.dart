import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../models/cart_model.dart';

/// All API communication lives here.
/// Controllers call this service; they never touch [http] directly.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const String _base = 'https://fakestoreapi.com';

  // ─── Auth ────────────────────────────────────────────────────────────────

  /// Returns a JWT token string on success, throws on failure.
  Future<String> login(String username, String password) async {
    final body = jsonEncode({'username': username, 'password': password});
    debugPrint('API LOGIN -> body: $body');
    final response = await http
        .post(
          Uri.parse('$_base/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 15));

    debugPrint(
      'API LOGIN <- status: ${response.statusCode} body: ${response.body}',
    );

    // FakeStore returns 200 or 201 depending on server version
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['token'] as String;
    }
    throw Exception('Login failed: ${response.statusCode} ${response.body}');
  }

  // ─── Users ───────────────────────────────────────────────────────────────

  Future<UserModel> getUser(int userId) async {
    final response = await http.get(Uri.parse('$_base/users/$userId'));
    if (response.statusCode == 200) {
      return UserModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to get user');
  }

  Future<List<UserModel>> getAllUsers() async {
    final response = await http.get(Uri.parse('$_base/users'));
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to get users');
  }

  // ─── Products ────────────────────────────────────────────────────────────

  Future<List<Product>> getAllProducts({String? sort}) async {
    final query = sort != null ? '?sort=$sort' : '';
    final response = await http.get(Uri.parse('$_base/products$query'));
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load products');
  }

  Future<Product> getProduct(int id) async {
    final response = await http.get(Uri.parse('$_base/products/$id'));
    if (response.statusCode == 200) {
      return Product.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to load product');
  }

  Future<List<String>> getCategories() async {
    final response = await http.get(Uri.parse('$_base/products/categories'));
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((c) => c as String).toList();
    }
    throw Exception('Failed to load categories');
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$_base/products/category/$category'),
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load products for category: $category');
  }

  // ─── Cart ─────────────────────────────────────────────────────────────────

  Future<List<CartModel>> getCarts() async {
    final response = await http.get(Uri.parse('$_base/carts'));
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((c) => CartModel.fromJson(c as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load carts');
  }

  Future<CartModel> getCart(int cartId) async {
    final response = await http.get(Uri.parse('$_base/carts/$cartId'));
    if (response.statusCode == 200) {
      return CartModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to load cart');
  }

  Future<List<CartModel>> getUserCarts(int userId) async {
    final response = await http.get(Uri.parse('$_base/carts/user/$userId'));
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((c) => CartModel.fromJson(c as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load user carts');
  }

  Future<CartModel> addCart({
    required int userId,
    required List<CartProduct> products,
  }) async {
    final body = jsonEncode({
      'userId': userId,
      'date': DateTime.now().toIso8601String().split('T').first,
      'products': products.map((p) => p.toJson()).toList(),
    });

    final response = await http.post(
      Uri.parse('$_base/carts'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CartModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to add cart');
  }

  Future<CartModel> updateCart({
    required int cartId,
    required int userId,
    required List<CartProduct> products,
  }) async {
    final body = jsonEncode({
      'userId': userId,
      'date': DateTime.now().toIso8601String().split('T').first,
      'products': products.map((p) => p.toJson()).toList(),
    });

    final response = await http.put(
      Uri.parse('$_base/carts/$cartId'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      return CartModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to update cart');
  }

  Future<CartModel> deleteCart(int cartId) async {
    final response = await http.delete(Uri.parse('$_base/carts/$cartId'));
    if (response.statusCode == 200) {
      return CartModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to delete cart');
  }
}
