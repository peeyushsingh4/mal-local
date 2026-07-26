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
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategoryId == cat.id;

          return Semantics(
            label: 'Filter by category ${cat.name}. ${isSelected ? 'Selected' : 'Not selected'}',
            button: true,
            selected: isSelected,
            child: InkWell(
              onTap: () => onSelectCategory(cat.id),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? BlinkitTheme.blinkitYellow
                      : (isDark ? BlinkitTheme.darkElevated : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? BlinkitTheme.blinkitYellow
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(cat.icon, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 11.5,
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
