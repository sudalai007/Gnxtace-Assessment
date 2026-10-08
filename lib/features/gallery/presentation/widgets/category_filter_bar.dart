import 'package:flutter/material.dart';
import '../../../../core/api/api_constants.dart';

class CategoryFilterBar extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: ApiConstants.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = ApiConstants.categories[index];
          final isSelected = cat.toLowerCase() == selectedCategory.toLowerCase();

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            child: ChoiceChip(
              showCheckmark: false,
              label: Text(
                cat.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                ),
              ),
              selected: isSelected,
              selectedColor: primaryColor,
              backgroundColor: theme.cardTheme.color,
              onSelected: (_) => onCategorySelected(cat),
            ),
          );
        },
      ),
    );
  }
}
