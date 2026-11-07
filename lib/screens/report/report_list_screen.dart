import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_colors.dart';
import '../../cubits/reports/report_cubit.dart';
import '../../cubits/reports/report_state.dart';
import '../../models/enums.dart';
import '../../models/report.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/report_card.dart';
import 'report_details_screen.dart';

/// Screen 4.
class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReportCubit cubit = context.read<ReportCubit>();
    final ReportState state = context.watch<ReportCubit>().state;
    final List<Report> visible = state.visible;

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: TextField(
              controller: _search,
              onChanged: cubit.search,
              decoration: InputDecoration(
                hintText: 'Search reports or locations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          cubit.search('');
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: <Widget>[
                _Filter(
                  label: 'All',
                  selected: state.statusFilter == null,
                  onTap: () => cubit.setStatusFilter(null),
                ),
                ...ReportStatus.values.map(
                  (ReportStatus status) => _Filter(
                    label: status.label,
                    selected: state.statusFilter == status,
                    onTap: () => cubit.setStatusFilter(status),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : visible.isEmpty
                    ? EmptyState(
                        icon: Icons.description_outlined,
                        title: 'No reports found',
                        message: state.query.isEmpty &&
                                state.statusFilter == null
                            ? 'Reports appear here as soon as they are submitted.'
                            : 'Try a different filter or search term.',
                        action: state.query.isEmpty &&
                                state.statusFilter == null
                            ? null
                            : OutlinedButton(
                                onPressed: () {
                                  _search.clear();
                                  cubit.search('');
                                  cubit.setStatusFilter(null);
                                  setState(() {});
                                },
                                child: const Text('Clear filters'),
                              ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: visible.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Report report = visible[index];
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

class _Filter extends StatelessWidget {
  const _Filter({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
