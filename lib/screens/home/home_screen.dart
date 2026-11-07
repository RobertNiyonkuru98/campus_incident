import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_colors.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/reports/report_cubit.dart';
import '../../cubits/reports/report_state.dart';
import '../../models/app_user.dart';
import '../../models/enums.dart';
import '../../models/report.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/report_card.dart';
import '../auth/auth_screen.dart';
import '../profile/profile_screen.dart';
import '../report/report_details_screen.dart';
import '../report/report_form_screen.dart';
import '../report/report_list_screen.dart';
import '../staff/staff_queue_screen.dart';

/// Screen 2. The landing surface after sign-in.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.watch<AuthCubit>().user;
    final ReportState reports = context.watch<ReportCubit>().state;

    if (user == null) return const AuthScreen();

    final List<Report> mine = reports.forUser(user.uid);
    final List<Report> recent = reports.reports.take(3).toList();

    return Scaffold(
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onHome: () {},
        onReports: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ReportListScreen()),
        ),
        onProfile: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ReportFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => context.read<ReportCubit>().watch(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
            children: <Widget>[
              _Greeting(user: user),
              const SizedBox(height: 18),
              _HeroCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ReportFormScreen(),
                  ),
                ),
              ),
              if (user.isStaff) ...<Widget>[
                const SizedBox(height: 12),
                _StaffBanner(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const StaffQueueScreen(),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              _SectionHeader(
                title: 'Report Summary',
                action: 'See all',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ReportListScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  _Stat(
                    label: 'My Reports',
                    value: mine.length,
                    colour: AppColors.primary,
                    icon: Icons.assignment_outlined,
                  ),
                  const SizedBox(width: 8),
                  _Stat(
                    label: 'Submitted',
                    value: reports.countOf(ReportStatus.submitted),
                    colour: AppColors.submittedFg,
                    icon: Icons.schedule,
                  ),
                  const SizedBox(width: 8),
                  _Stat(
                    label: 'In Progress',
                    value: reports.countOf(ReportStatus.inProgress),
                    colour: AppColors.inProgressFg,
                    icon: Icons.autorenew,
                  ),
                  const SizedBox(width: 8),
                  _Stat(
                    label: 'Resolved',
                    value: reports.countOf(ReportStatus.resolved),
                    colour: AppColors.resolvedFg,
                    icon: Icons.check_circle_outline,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _SectionHeader(
                title: 'Recent Reports',
                action: 'See all',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ReportListScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (reports.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (recent.isEmpty)
                const EmptyState(
                  icon: Icons.description_outlined,
                  title: 'No reports yet',
                  message: 'Reports submitted by anyone on campus appear here.',
                )
              else
                ...recent.map(
                  (Report report) => ReportCard(
                    report: report,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReportDetailsScreen(report: report),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final int hour = DateTime.now().hour;
    final String part = hour < 12
        ? 'Good morning'
        : (hour < 17 ? 'Good afternoon' : 'Good evening');

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$part, ${user.name.split(' ').first}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Keep our campus safe.',
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(
            user.initials,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'See an issue on campus?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Report it and help improve our learning environment.',
            style: TextStyle(fontSize: 12.5, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(999),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.add_circle, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Report an Issue',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.chevron_right,
                        size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffBanner extends StatelessWidget {
  const _StaffBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.inProgressBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.shield_outlined,
                size: 18, color: AppColors.inProgressFg),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Staff access - you can update report statuses.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inProgressFg,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.inProgressFg),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.colour,
    required this.icon,
  });

  final String label;
  final int value;
  final Color colour;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: colour.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: colour),
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
