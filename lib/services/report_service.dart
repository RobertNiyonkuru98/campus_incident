import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/enums.dart';
import '../models/report.dart';

/// The only class that reads or writes the `reports` collection.
class ReportService {
  ReportService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, Object?>> get _reports =>
      _db.collection('reports');

  /// One indexed query; status and text filtering happen on the client so the
  /// app needs no composite indexes and filtering feels instant.
  Stream<List<Report>> watchReports() {
    return _reports
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, Object?>> snap) =>
            snap.docs.map(Report.fromDoc).toList());
  }

  Future<String> create(Report report) async {
    final DocumentReference<Map<String, Object?>> ref =
        await _reports.add(report.toCreateMap());
    return ref.id;
  }

  /// Staff-only. The security rules are what actually enforce this; the app
  /// also hides the control, but hiding is not security.
  Future<void> updateStatus({
    required Report report,
    required ReportStatus status,
    required AppUser by,
    String note = '',
  }) async {
    final Map<String, Object?> update = <String, Object?>{
      'status': status.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
      // arrayUnion cannot hold a sentinel, so this uses the device clock.
      'timeline': FieldValue.arrayUnion(<Map<String, Object?>>[
        <String, Object?>{
          'status': status.firestoreValue,
          'at': Timestamp.now(),
          'byUid': by.uid,
          'byName': by.name,
          'note': note,
        },
      ]),
    };

    if (note.isNotEmpty) update['staffNotes'] = note;
    if (status == ReportStatus.resolved) {
      update['resolvedAt'] = FieldValue.serverTimestamp();
    }

    await _reports.doc(report.id).update(update);
  }
}
