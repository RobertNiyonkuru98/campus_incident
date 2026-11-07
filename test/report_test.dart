import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_incident/models/enums.dart';
import 'package:campus_incident/models/report.dart';
import 'package:flutter_test/flutter_test.dart';

Report sample() => const Report(
      id: 'r1',
      title: 'Water shortage',
      description: 'No water since this morning on the second floor.',
      category: ReportCategory.water,
      locationLabel: 'Block B - Room 204',
      submittedByUid: 'u1',
      submittedByName: 'Amina Hassan',
      photoUrls: <String>['https://example.com/a.jpg'],
    );

void main() {
  group('Report.toCreateMap', () {
    test('always writes the initial submitted status', () {
      final Map<String, Object?> map = sample().toCreateMap();
      expect(map['status'], 'submitted');
    });

    test('stores the category as its Firestore value, not the enum name', () {
      expect(sample().toCreateMap()['category'], 'water');
    });

    test('denormalises the reporter so lists need no second read', () {
      final Map<String, Object?> map = sample().toCreateMap();
      final Map<String, Object?> by = map['submittedBy']! as Map<String, Object?>;
      expect(by['uid'], 'u1');
      expect(by['name'], 'Amina Hassan');
    });

    test('seeds the timeline with the submission event', () {
      final List<Object?> timeline =
          sample().toCreateMap()['timeline']! as List<Object?>;
      expect(timeline, hasLength(1));
    });

    test('timeline entries carry a concrete Timestamp, never a FieldValue', () {
      // Firestore rejects FieldValue sentinels nested inside an array. This made
      // every submission fail with an invisible invalid-argument error, so it is
      // pinned here as a regression test.
      final List<Object?> timeline =
          sample().toCreateMap()['timeline']! as List<Object?>;
      final Map<String, Object?> first =
          timeline.first! as Map<String, Object?>;
      expect(first['at'], isA<Timestamp>());
      expect(first['at'], isNot(isA<FieldValue>()));
    });

    test('never sends a client timestamp for createdAt', () {
      // createdAt must be a FieldValue.serverTimestamp() sentinel, never a
      // device Timestamp - otherwise a wrong phone clock corrupts ordering.
      final Object? createdAt = sample().toCreateMap()['createdAt'];
      expect(createdAt, isA<FieldValue>());
      expect(createdAt, isNot(isA<Timestamp>()));
    });
  });

  group('Report.copyWith', () {
    test('changes only the fields asked for', () {
      final Report updated =
          sample().copyWith(status: ReportStatus.resolved);
      expect(updated.status, ReportStatus.resolved);
      expect(updated.id, 'r1');
      expect(updated.title, 'Water shortage');
    });
  });
}
