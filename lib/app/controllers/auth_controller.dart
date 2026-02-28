import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../routes/app_routes.dart';

/// Owns login state and persists it via SharedPreferences.
class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final _isLoading = false.obs;
  final _token = ''.obs;
  final _user = Rxn<UserModel>();
  final _userId = 0.obs;

  bool get isLoading => _isLoading.value;
  String get token => _token.value;
  UserModel? get user => _user.value;
  bool get isLoggedIn => _token.value.isNotEmpty;

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_tokenKey) ?? '';
    final savedId = prefs.getInt(_userIdKey) ?? 0;

    if (saved.isNotEmpty && savedId > 0) {
      _token.value = saved;
      _userId.value = savedId;
      await _fetchUser(savedId);
    }
  }

  Future<void> login(String username, String password) async {
    _isLoading.value = true;
    try {
      final tkn = await ApiService.instance.login(username, password);
      _token.value = tkn;

      // Decode JWT payload to extract the real user id (sub field)
      final userId = _decodeJwtUserId(tkn);
      _userId.value = userId;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, tkn);
      await prefs.setInt(_userIdKey, userId);

      await _fetchUser(userId);
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');
      String msg;
      final err = e.toString();
      if (err.contains('SocketException') || err.contains('TimeoutException')) {
        msg = 'Network error — check your connection';
      } else if (err.contains('401')) {
        msg = 'Wrong username or password (401)';
      } else {
        // Show the real error so we can diagnose
        msg = err.replaceFirst('Exception: ', '');
      }
      Get.snackbar(
        'Login Failed',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 8),
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _fetchUser(int userId) async {
    try {
      final u = await ApiService.instance.getUser(userId);
      _user.value = u;
    } catch (_) {
      // silently fail – profile data is non-critical
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    _token.value = '';
    _user.value = null;
    _userId.value = 0;
    Get.offAllNamed(AppRoutes.login);
  }

  int get userId => _userId.value;

  /// Decodes the JWT payload (base64) to extract the `sub` (user id).
  /// No external package needed — FakeStore tokens are standard HS256 JWTs.
  int _decodeJwtUserId(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 1;
      // Base64url decode the payload (add padding if needed)
      String payload = parts[1];
      payload = payload.padRight(
        payload.length + (4 - payload.length % 4) % 4,
        '=',
      );
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      return (map['sub'] as num?)?.toInt() ?? 1;
    } catch (_) {
      return 1;
    }
  }
}
