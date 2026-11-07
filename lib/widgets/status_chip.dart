import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../models/enums.dart';

(Color, Color) statusColors(ReportStatus status) {
  switch (status) {
    case ReportStatus.submitted:
      return (AppColors.submittedFg, AppColors.submittedBg);
    case ReportStatus.inProgress:
      return (AppColors.inProgressFg, AppColors.inProgressBg);
    case ReportStatus.resolved:
      return (AppColors.resolvedFg, AppColors.resolvedBg);
  }
}

/// The pill used everywhere a report status appears.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.dense = false});

  final ReportStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final (Color fg, Color bg) = statusColors(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: fg,
              fontSize: dense ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
