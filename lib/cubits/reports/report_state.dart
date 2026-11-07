import '../../models/enums.dart';
import '../../models/report.dart';

/// One immutable state object. Derived getters do the filtering so the widget
/// never has to: the UI just renders `visible`.
class ReportState {
  const ReportState({
    this.reports = const <Report>[],
    this.loading = true,
    this.saving = false,
    this.error,
    this.statusFilter,
    this.categoryFilter,
    this.query = '',
  });

  final List<Report> reports;
  final bool loading;
  final bool saving;
  final String? error;
  final ReportStatus? statusFilter;
  final ReportCategory? categoryFilter;
  final String query;

  List<Report> get visible {
    final String q = query.trim().toLowerCase();
    return reports.where((Report r) {
      final bool statusOk = statusFilter == null || r.status == statusFilter;
      final bool categoryOk =
          categoryFilter == null || r.category == categoryFilter;
      final bool queryOk = q.isEmpty ||
          r.title.toLowerCase().contains(q) ||
          r.locationLabel.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q);
      return statusOk && categoryOk && queryOk;
    }).toList();
  }

  List<Report> forUser(String uid) =>
      reports.where((Report r) => r.submittedByUid == uid).toList();

  int countOf(ReportStatus status) =>
      reports.where((Report r) => r.status == status).length;

  ReportState copyWith({
    List<Report>? reports,
    bool? loading,
    bool? saving,
    String? error,
    bool clearError = false,
    ReportStatus? statusFilter,
    bool clearStatusFilter = false,
    ReportCategory? categoryFilter,
    bool clearCategoryFilter = false,
    String? query,
  }) =>
      ReportState(
        reports: reports ?? this.reports,
        loading: loading ?? this.loading,
        saving: saving ?? this.saving,
        error: clearError ? null : (error ?? this.error),
        statusFilter:
            clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
        categoryFilter: clearCategoryFilter
            ? null
            : (categoryFilter ?? this.categoryFilter),
        query: query ?? this.query,
      );
}
