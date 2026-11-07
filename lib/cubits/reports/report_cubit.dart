import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/enums.dart';
import '../../models/report.dart';
import '../../services/report_service.dart';
import 'report_state.dart';

/// Owns the report feed: the live Firestore stream, the filters and search,
/// and submitting a new report.
class ReportCubit extends Cubit<ReportState> {
  ReportCubit(this._service) : super(const ReportState());

  final ReportService _service;
  StreamSubscription<List<Report>>? _subscription;

  void watch() {
    _subscription?.cancel();
    _subscription = _service.watchReports().listen(
      (List<Report> reports) {
        emit(state.copyWith(reports: reports, loading: false, clearError: true));
      },
      onError: (Object error) {
        emit(state.copyWith(
          loading: false,
          error: 'Could not load reports. Check your connection.',
        ));
      },
    );
  }

  /// Cancels the Firestore listener and forgets the data. Called on sign-out so
  /// a signed-out user never holds a live subscription.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    emit(const ReportState());
  }

  void setStatusFilter(ReportStatus? status) {
    emit(state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
    ));
  }

  void setCategoryFilter(ReportCategory? category) {
    emit(state.copyWith(
      categoryFilter: category,
      clearCategoryFilter: category == null,
    ));
  }

  void search(String query) => emit(state.copyWith(query: query));

  Future<bool> submit(Report report) async {
    emit(state.copyWith(saving: true, clearError: true));
    try {
      await _service.create(report);
      emit(state.copyWith(saving: false));
      return true;
    } catch (error) {
      debugPrint('Report submit failed: $error');
      emit(state.copyWith(
        saving: false,
        error: 'Could not submit the report. Please try again.',
      ));
      return false;
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
