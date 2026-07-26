import 'package:flutter/material.dart';
import '../../domain/models/category.dart';
import '../theme/blinkit_theme.dart';

class CategoryScrollBar extends StatelessWidget {
  final String selectedCategoryId;
  final ValueChanged<String> onSelectCategory;

  const CategoryScrollBar({
    super.key,
    required this.selectedCategoryId,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      const ListingCategory(
        id: 'all',
        name: 'All Items',
        icon: '⚡',
        color: BlinkitTheme.blinkitYellow,
        bgTint: Color(0xFFFFF9E6),
      ),
      ...ListingCategory.all,
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategoryId == cat.id;

          return Semantics(
            label: 'Filter by category ${cat.name}. ${isSelected ? 'Selected' : 'Not selected'}',
            button: true,
            selected: isSelected,
            child: InkWell(
              onTap: () => onSelectCategory(cat.id),
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? BlinkitTheme.blinkitYellow
                      : (isDark ? BlinkitTheme.darkElevated : Colors.white),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? BlinkitTheme.blinkitYellow
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: BlinkitTheme.blinkitYellow.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Text(cat.icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF0C831F)
                            : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
