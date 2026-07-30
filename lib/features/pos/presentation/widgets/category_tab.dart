import 'package:coffee_pos/core/constant/app_colors.dart';
import 'package:coffee_pos/core/constant/app_sizes.dart';
import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';

class CategoryTab extends StatelessWidget {
  const CategoryTab({
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
    return Container(
      width: AppSizes.categoryWidth,
      color: AppColors.surfaceVar,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.sm,
        ),
        children: [
          // Semua
          _CategoryItem(
            label: 'Semua',
            icon: Icons.grid_view,
            isSelected: selectedId == null,
            onTap: () => onSelect(null),
          ),
          const Divider(height: 1),
          ...categories.map((cat) => _CategoryItem(
            label: cat.name,
            icon: Icons.coffee_outlined,
            isSelected: selectedId == cat.id,
            onTap: () => onSelect(cat.id),
          )),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.md,
          horizontal: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected
                ? AppColors.primary
                : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
                color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}