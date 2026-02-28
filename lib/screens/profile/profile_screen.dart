import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/controllers/auth_controller.dart';
import '../../app/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Obx(() {
        final user = AuthController.to.user;
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile header
              Container(
                width: double.infinity,
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.accent,
                      child: Text(
                        user.name.firstname.isNotEmpty
                            ? user.name.firstname[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.name.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user.username}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Info cards
              _InfoCard(
                title: 'Contact Information',
                items: [
                  _InfoItem(Icons.email_outlined, 'Email', user.email),
                  _InfoItem(Icons.phone_outlined, 'Phone', user.phone),
                  _InfoItem(Icons.person_outline, 'Username', user.username),
                ],
              ),

              const SizedBox(height: 8),

              _InfoCard(
                title: 'Account',
                items: [
                  _InfoItem(Icons.badge_outlined, 'User ID', '${user.id}'),
                ],
              ),

              const SizedBox(height: 8),

              // Quick actions
              _ActionCard(
                title: 'Quick Actions',
                actions: [
                  _ActionItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'My Orders',
                    onTap: () => Get.snackbar(
                      'Orders',
                      'Order history coming soon!',
                      snackPosition: SnackPosition.BOTTOM,
                    ),
                  ),
                  _ActionItem(
                    icon: Icons.favorite_border,
                    label: 'Wishlist',
                    onTap: () => Get.snackbar(
                      'Wishlist',
                      'Wishlist coming soon!',
                      snackPosition: SnackPosition.BOTTOM,
                    ),
                  ),
                  _ActionItem(
                    icon: Icons.location_on_outlined,
                    label: 'Addresses',
                    onTap: () => Get.snackbar(
                      'Addresses',
                      'Address management coming soon!',
                      snackPosition: SnackPosition.BOTTOM,
                    ),
                  ),
                  _ActionItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    color: AppColors.errorColor,
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              AuthController.to.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;
  const _InfoCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingS),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(title, style: AppTextStyles.heading3),
          ),
          const Divider(height: 1),
          ...items.map((item) => _buildRow(item)),
        ],
      ),
    );
  }

  Widget _buildRow(_InfoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: 12,
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: AppTextStyles.caption),
                Text(item.value, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem(this.icon, this.label, this.value);
}

class _ActionCard extends StatelessWidget {
  final String title;
  final List<_ActionItem> actions;
  const _ActionCard({required this.title, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingS),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(title, style: AppTextStyles.heading3),
          ),
          const Divider(height: 1),
          ...actions.map((a) => _buildAction(a)),
        ],
      ),
    );
  }

  Widget _buildAction(_ActionItem a) {
    return InkWell(
      onTap: a.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(a.icon, size: 20, color: a.color ?? AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                a.label,
                style: AppTextStyles.body.copyWith(
                  color: a.color ?? AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: a.color ?? AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
}
