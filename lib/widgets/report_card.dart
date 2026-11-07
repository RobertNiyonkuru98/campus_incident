import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/fmt.dart';
import '../models/report.dart';
import 'category_tile.dart';
import 'status_chip.dart';

/// One row in any report list.
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    required this.onTap,
    this.trailing,
  });

  final Report report;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final (Color catFg, Color catBg, IconData catIcon) =
        categoryStyle(report.category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: AppTheme.card,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 58,
                height: 58,
                child: report.firstPhoto.isEmpty
                    ? Container(
                        color: catBg,
                        child: Icon(catIcon, color: catFg, size: 24),
                      )
                    : Image.network(
                        report.firstPhoto,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: catBg,
                          child: Icon(catIcon, color: catFg, size: 24),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    report.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.place_outlined,
                          size: 12, color: AppColors.muted),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          report.locationLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    Fmt.timeAgo(report.createdAt),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      StatusChip(status: report.status, dense: true),
                      const Spacer(),
                      ?trailing,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
