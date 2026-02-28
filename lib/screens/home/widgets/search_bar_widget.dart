import 'package:flutter/material.dart';
import '../../../app/controllers/product_controller.dart';
import '../../../app/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SearchBarWidget — pill-shaped TextField wired to ProductController.searchQuery.
// Typing filters products live. Clear (×) button appears when there is text.
// ─────────────────────────────────────────────────────────────────────────────

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _ctrl = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _ctrl.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
    ProductController.to.searchQuery.value = _ctrl.text;
  }

  void _clear() {
    _ctrl.clear();
    ProductController.to.searchQuery.value = '';
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTextChanged);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Search products…',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _hasText
                ? GestureDetector(
                    key: const ValueKey('clear'),
                    onTap: _clear,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('empty'), width: 10),
          ),
        ],
      ),
    );
  }
}
