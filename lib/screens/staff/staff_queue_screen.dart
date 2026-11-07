import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_colors.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/reports/report_cubit.dart';
import '../../cubits/reports/report_state.dart';
import '../../models/app_user.dart';
import '../../models/enums.dart';
import '../../models/report.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/report_card.dart';
import '../report/report_details_screen.dart';

/// Screen 6. Staff only.
///
/// The screen is hidden from students, but that is only the first layer: the
/// Firestore rules reject a status write from a non-staff account regardless of
/// what the app shows. Hiding a button is UX; the rules are the security.
class StaffQueueScreen extends StatelessWidget {
  const StaffQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.watch<AuthCubit>().user;
    final ReportState state = context.watch<ReportCubit>().state;

    if (user == null || !user.isStaff) {
      return Scaffold(
        appBar: AppBar(title: const Text('Staff Queue')),
        body: const EmptyState(
          icon: Icons.lock_outline,
          title: 'Staff access only',
          message:
              'Your account does not have the staff role. Ask an administrator '
              'to update your profile in the users collection.',
        ),
      );
    }

    final List<Report> open = state.reports
        .where((Report r) => r.status != ReportStatus.resolved)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Incident Queue')),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.inProgressBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: <Widget>[
                Icon(Icons.shield_outlined,
                    size: 16, color: AppColors.inProgressFg),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Staff access - you can update report statuses.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inProgressFg,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: <Widget>[
                _Summary(
                  label: 'Open',
                  value: open.length,
                  colour: AppColors.submittedFg,
                ),
                const SizedBox(width: 8),
                _Summary(
                  label: 'In Progress',
                  value: state.countOf(ReportStatus.inProgress),
                  colour: AppColors.inProgressFg,
                ),
                const SizedBox(width: 8),
                _Summary(
                  label: 'Resolved',
                  value: state.countOf(ReportStatus.resolved),
                  colour: AppColors.resolvedFg,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : open.isEmpty
                    ? const EmptyState(
                        icon: Icons.check_circle_outline,
                        title: 'Queue is clear',
                        message: 'Every report has been resolved. Nice work.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: open.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Report report = open[index];
                          return ReportCard(
                            report: report,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    ReportDetailsScreen(report: report),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.label,
    required this.value,
    required this.colour,
  });

  final String label;
  final int value;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: colour.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: <Widget>[
            Text(
              '$value',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colour,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10.5, color: colour),
            ),
          ],
        ),
      ),
    );
  }
}
