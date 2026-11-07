import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../models/enums.dart';

(Color, Color, IconData) categoryStyle(ReportCategory category) {
  switch (category) {
    case ReportCategory.facilities:
      return (AppColors.facilitiesFg, AppColors.facilitiesBg, Icons.apartment_outlined);
    case ReportCategory.water:
      return (AppColors.waterFg, AppColors.waterBg, Icons.water_drop_outlined);
    case ReportCategory.electricity:
      return (AppColors.electricityFg, AppColors.electricityBg, Icons.bolt_outlined);
    case ReportCategory.safety:
      return (AppColors.safetyFg, AppColors.safetyBg, Icons.shield_outlined);
    case ReportCategory.sanitation:
      return (AppColors.sanitationFg, AppColors.sanitationBg, Icons.cleaning_services_outlined);
  }
}

/// One selectable category square on the report form.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final ReportCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (Color fg, Color bg, IconData icon) = categoryStyle(category);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? fg : bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? fg : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 22, color: selected ? Colors.white : fg),
            const SizedBox(height: 6),
            Text(
              category.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
