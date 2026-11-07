import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/app_user.dart';
import '../../models/enums.dart';
import '../../core/status_machine.dart';
import '../../models/report.dart';
import '../../services/report_service.dart';

/// Saving states for a staff action. Deliberately tiny: one operation.
sealed class StaffState {
  const StaffState();
}

class StaffIdle extends StaffState {
  const StaffIdle();
}

class StaffSaving extends StaffState {
  const StaffSaving();
}

class StaffSaved extends StaffState {
  const StaffSaved();
}

class StaffFailure extends StaffState {
  const StaffFailure(this.message);
  final String message;
}

/// Owns status changes. Separate from ReportCubit so the staff workflow - and
/// its permission failure - is one small, testable unit.
class StaffCubit extends Cubit<StaffState> {
  StaffCubit(this._service) : super(const StaffIdle());

  final ReportService _service;

  Future<bool> updateStatus({
    required Report report,
    required ReportStatus status,
    required AppUser by,
    String note = '',
  }) async {
    if (!by.isStaff) {
      emit(const StaffFailure('Only staff can update a report status.'));
      return false;
    }
    if (!StatusMachine.canTransition(report.status, status)) {
      emit(StaffFailure(
        'A ${report.status.label} report cannot move straight to '
        '${status.label}.',
      ));
      return false;
    }

    emit(const StaffSaving());
    try {
      await _service.updateStatus(
        report: report,
        status: status,
        by: by,
        note: note,
      );
      emit(const StaffSaved());
      return true;
    } catch (error) {
      emit(const StaffFailure(
        'Update failed. Check your connection or your staff permissions.',
      ));
      return false;
    }
  }

  void reset() => emit(const StaffIdle());
}
