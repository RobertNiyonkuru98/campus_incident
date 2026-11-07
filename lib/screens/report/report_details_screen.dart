import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_colors.dart';
import '../../core/app_theme.dart';
import '../../core/fmt.dart';
import '../../core/status_machine.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/staff/staff_cubit.dart';
import '../../models/app_user.dart';
import '../../models/enums.dart';
import '../../models/report.dart';
import '../../widgets/status_chip.dart';

/// Screen 5. Every role can read this screen; only staff get the update card.
class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key, required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.watch<AuthCubit>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Incident Details')),
      body: BlocListener<StaffCubit, StaffState>(
        listenWhen: (StaffState previous, StaffState current) =>
            current is StaffSaved || current is StaffFailure,
        listener: (BuildContext context, StaffState state) {
          final String message = state is StaffFailure
              ? state.message
              : 'Report updated.';
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(message),
                behavior: SnackBarBehavior.floating,
                backgroundColor:
                    state is StaffFailure ? AppColors.danger : AppColors.resolvedFg,
              ),
            );
          if (state is StaffSaved) context.read<StaffCubit>().reset();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: <Widget>[
            if (report.firstPhoto.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  report.firstPhoto,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 120,
                    color: AppColors.border,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                StatusChip(status: report.status),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.card,
              child: Column(
                children: <Widget>[
                  _Meta(
                    icon: Icons.place_outlined,
                    text: report.locationLabel,
                  ),
                  const Divider(height: 18),
                  _Meta(
                    icon: Icons.category_outlined,
                    text: report.category.label,
                  ),
                  const Divider(height: 18),
                  _Meta(
                    icon: Icons.calendar_today_outlined,
                    text: 'Submitted ${Fmt.dateTime(report.createdAt)}',
                  ),
                  const Divider(height: 18),
                  _Meta(
                    icon: Icons.person_outline,
                    text: 'Reported by ${report.submittedByName}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Timeline(report: report),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.description,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            if (report.staffNotes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.inProgressBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Staff note',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inProgressFg,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      report.staffNotes,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.inProgressFg,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (user != null && user.isStaff) ...<Widget>[
              const SizedBox(height: 18),
              _StaffUpdateCard(report: report, by: user),
            ],
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: AppColors.muted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, color: AppColors.ink),
          ),
        ),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Status Timeline',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          ...report.timeline.asMap().entries.map(
                (MapEntry<int, StatusEvent> entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: statusColors(entry.value.status).$1,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (entry.key != report.timeline.length - 1)
                            Container(
                              width: 2,
                              height: 26,
                              color: AppColors.border,
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              entry.value.status.label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              Fmt.dateTime(entry.value.at),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                            if (entry.value.note.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  entry.value.note,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _StaffUpdateCard extends StatefulWidget {
  const _StaffUpdateCard({required this.report, required this.by});

  final Report report;
  final AppUser by;

  @override
  State<_StaffUpdateCard> createState() => _StaffUpdateCardState();
}

class _StaffUpdateCardState extends State<_StaffUpdateCard> {
  final TextEditingController _note = TextEditingController();
  ReportStatus? _target;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<ReportStatus> options =
        StatusMachine.nextOptions(widget.report.status);
    final bool saving = context.watch<StaffCubit>().state is StaffSaving;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.inProgressBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inProgressFg.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Update Status  (staff only)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.inProgressFg,
            ),
          ),
          const SizedBox(height: 10),
          if (options.isEmpty)
            const Text(
              'No further transitions are available for this report.',
              style: TextStyle(fontSize: 12.5, color: AppColors.ink),
            )
          else ...<Widget>[
            Wrap(
              spacing: 8,
              children: options.map((ReportStatus option) {
                final bool selected = _target == option;
                return ChoiceChip(
                  label: Text(option.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _target = option),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _note,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Staff note (optional)',
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: _target == null || saving
                  ? null
                  : () => context.read<StaffCubit>().updateStatus(
                        report: widget.report,
                        status: _target!,
                        by: widget.by,
                        note: _note.text.trim(),
                      ),
              child: Text(saving ? 'Saving...' : 'Update Report'),
            ),
          ],
        ],
      ),
    );
  }
}
