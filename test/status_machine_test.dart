import 'package:campus_incident/core/status_machine.dart';
import 'package:campus_incident/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatusMachine.canTransition', () {
    test('submitted can only move to inProgress', () {
      expect(
        StatusMachine.canTransition(
            ReportStatus.submitted, ReportStatus.inProgress),
        isTrue,
      );
      expect(
        StatusMachine.canTransition(
            ReportStatus.submitted, ReportStatus.resolved),
        isFalse,
      );
      expect(
        StatusMachine.canTransition(
            ReportStatus.submitted, ReportStatus.submitted),
        isFalse,
      );
    });

    test('inProgress can resolve or go back to submitted', () {
      expect(
        StatusMachine.canTransition(
            ReportStatus.inProgress, ReportStatus.resolved),
        isTrue,
      );
      expect(
        StatusMachine.canTransition(
            ReportStatus.inProgress, ReportStatus.submitted),
        isTrue,
      );
    });

    test('resolved reopens only through inProgress', () {
      expect(
        StatusMachine.canTransition(
            ReportStatus.resolved, ReportStatus.inProgress),
        isTrue,
      );
      expect(
        StatusMachine.canTransition(
            ReportStatus.resolved, ReportStatus.submitted),
        isFalse,
      );
    });
  });

  group('StatusMachine.nextOptions', () {
    test('a submitted report offers exactly one next step', () {
      expect(StatusMachine.nextOptions(ReportStatus.submitted),
          <ReportStatus>[ReportStatus.inProgress]);
    });

    test('a resolved report offers inProgress only', () {
      expect(StatusMachine.nextOptions(ReportStatus.resolved),
          <ReportStatus>[ReportStatus.inProgress]);
    });
  });
}
