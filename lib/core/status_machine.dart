import '../models/enums.dart';

/// Legal status transitions. Pure, so it is unit-tested and shared by the Cubit
/// and the UI rather than re-implemented in each.
class StatusMachine {
  const StatusMachine._();

  static bool canTransition(ReportStatus from, ReportStatus to) {
    if (from == to) return false;
    switch (from) {
      case ReportStatus.submitted:
        return to == ReportStatus.inProgress;
      case ReportStatus.inProgress:
        return to == ReportStatus.resolved || to == ReportStatus.submitted;
      case ReportStatus.resolved:
        // A resolved report is reopened through In Progress, never straight
        // back to Submitted.
        return to == ReportStatus.inProgress;
    }
  }

  /// The statuses a staff member may pick from, given the current one.
  static List<ReportStatus> nextOptions(ReportStatus from) => ReportStatus.values
      .where((ReportStatus s) => canTransition(from, s))
      .toList();
}
