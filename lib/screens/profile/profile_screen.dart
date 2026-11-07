import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_colors.dart';
import '../../core/app_theme.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/reports/report_cubit.dart';
import '../../cubits/reports/report_state.dart';
import '../../models/app_user.dart';
import '../../models/enums.dart';
import '../staff/staff_queue_screen.dart';

/// Screen 7.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.watch<AuthCubit>().user;
    final ReportState reports = context.watch<ReportCubit>().state;

    if (user == null) {
      return const SizedBox.shrink();
    }

    final int mine = reports.forUser(user.uid).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: user.isStaff
                        ? AppColors.inProgressBg
                        : AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        user.isStaff ? Icons.verified_user : Icons.school,
                        size: 13,
                        color: user.isStaff
                            ? AppColors.inProgressFg
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        user.role.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: user.isStaff
                              ? AppColors.inProgressFg
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (user.isStaff && user.department.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    'Department - ${user.department}',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: AppTheme.card,
            child: Row(
              children: <Widget>[
                _Stat(label: 'My Reports', value: mine),
                _Stat(
                  label: 'In Progress',
                  value: reports.countOf(ReportStatus.inProgress),
                ),
                _Stat(
                  label: 'Resolved',
                  value: reports.countOf(ReportStatus.resolved),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: AppTheme.card,
            child: Column(
              children: <Widget>[
                if (user.isStaff)
                  ListTile(
                    leading: const Icon(Icons.inbox_outlined,
                        color: AppColors.primary),
                    title: const Text('Staff Queue'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const StaffQueueScreen(),
                      ),
                    ),
                  ),
                const ListTile(
                  leading: Icon(Icons.notifications_none),
                  title: Text('Notification Settings'),
                  trailing: Icon(Icons.chevron_right),
                ),
                const ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('Help & Support'),
                  trailing: Icon(Icons.chevron_right),
                ),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About CampusCare'),
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: () async {
              final AuthCubit auth = context.read<AuthCubit>();
              final NavigatorState navigator = Navigator.of(context);
              await auth.signOut();
              // This screen is a pushed route. Without popping back to the root
              // it stays on top of the login screen, and because `user` is now
              // null it renders an endless spinner.
              navigator.popUntil((Route<dynamic> route) => route.isFirst);
            },
            icon: const Icon(Icons.logout, color: AppColors.danger),
            label: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
