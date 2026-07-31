import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';

class CategoryHorizontal extends StatelessWidget {
  const CategoryHorizontal({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<CategoriesTableData> categories;
  final int? selectedId;
  final void Function(int?) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
        ),
        children: [
          _Chip(
            label: 'Semua',
            isSelected: selectedId == null,
            onTap: () => onSelect(null),
          ),
          ...categories.map((cat) => _Chip(
            label: cat.name,
            isSelected: selectedId == cat.id,
            onTap: () => onSelect(cat.id),
          )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.xs),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected
              ? Colors.white
              : AppColors.textPrimary,
            fontWeight: isSelected
              ? FontWeight.bold
              : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surfaceVar,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppSizes.radiusFull,
          ),
          side: BorderSide(
            color: isSelected
              ? AppColors.primary
              : AppColors.border,
          ),
        ),
        onSelected: (_) => onTap(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
        ),
      ),
    );
  }
}