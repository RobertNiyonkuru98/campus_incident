import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// One entry in a report's audit trail.
class StatusEvent {
  final ReportStatus status;
  final DateTime? at;
  final String byUid;
  final String byName;
  final String note;

  const StatusEvent({
    required this.status,
    this.at,
    this.byUid = '',
    this.byName = '',
    this.note = '',
  });

  Map<String, Object?> toMap() => <String, Object?>{
        'status': status.firestoreValue,
        'at': FieldValue.serverTimestamp(),
        'byUid': byUid,
        'byName': byName,
        'note': note,
      };

  factory StatusEvent.fromMap(Map<String, Object?> map) => StatusEvent(
        status: statusFromValue(map['status'] as String?),
        at: (map['at'] as Timestamp?)?.toDate(),
        byUid: (map['byUid'] as String?) ?? '',
        byName: (map['byName'] as String?) ?? '',
        note: (map['note'] as String?) ?? '',
      );
}

/// A campus incident report. Maps 1:1 onto `reports/{reportId}`.
class Report {
  final String id;
  final String title;
  final String description;
  final ReportCategory category;
  final String locationLabel;
  final List<String> photoUrls;
  final ReportStatus status;
  final String priority;
  final String submittedByUid;
  final String submittedByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final String staffNotes;
  final List<StatusEvent> timeline;

  const Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.locationLabel,
    required this.submittedByUid,
    required this.submittedByName,
    this.photoUrls = const <String>[],
    this.status = ReportStatus.submitted,
    this.priority = '',
    this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.staffNotes = '',
    this.timeline = const <StatusEvent>[],
  });

  String get firstPhoto => photoUrls.isEmpty ? '' : photoUrls.first;

  Report copyWith({
    ReportStatus? status,
    String? priority,
    String? staffNotes,
    List<StatusEvent>? timeline,
    DateTime? resolvedAt,
  }) =>
      Report(
        id: id,
        title: title,
        description: description,
        category: category,
        locationLabel: locationLabel,
        submittedByUid: submittedByUid,
        submittedByName: submittedByName,
        photoUrls: photoUrls,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        createdAt: createdAt,
        updatedAt: updatedAt,
        resolvedAt: resolvedAt ?? this.resolvedAt,
        staffNotes: staffNotes ?? this.staffNotes,
        timeline: timeline ?? this.timeline,
      );

  /// Note: `createdAt` is written with FieldValue.serverTimestamp(), so it is
  /// deliberately omitted here - the server owns that value.
  Map<String, Object?> toCreateMap() => <String, Object?>{
        'title': title,
        'description': description,
        'category': category.firestoreValue,
        'location': <String, Object?>{'label': locationLabel},
        'photoUrls': photoUrls,
        'status': ReportStatus.submitted.firestoreValue,
        'priority': '',
        'submittedBy': <String, Object?>{
          'uid': submittedByUid,
          'name': submittedByName,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'staffNotes': '',
        // Sentinels are not valid inside arrays, so this needs a Timestamp.
        'timeline': <Map<String, Object?>>[
          <String, Object?>{
            'status': ReportStatus.submitted.firestoreValue,
            'at': Timestamp.now(),
            'byUid': submittedByUid,
            'byName': submittedByName,
            'note': 'Report submitted',
          },
        ],
      };

  factory Report.fromDoc(DocumentSnapshot<Map<String, Object?>> doc) {
    final Map<String, Object?> map = doc.data() ?? <String, Object?>{};
    final Map<String, Object?> submittedBy =
        (map['submittedBy'] as Map<String, Object?>?) ?? <String, Object?>{};
    final Map<String, Object?> location =
        (map['location'] as Map<String, Object?>?) ?? <String, Object?>{};

    return Report(
      id: doc.id,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      category: categoryFromValue(map['category'] as String?),
      locationLabel: (location['label'] as String?) ?? 'Unknown location',
      photoUrls: ((map['photoUrls'] as List<Object?>?) ?? <Object?>[])
          .map((Object? e) => e.toString())
          .toList(),
      status: statusFromValue(map['status'] as String?),
      priority: (map['priority'] as String?) ?? '',
      submittedByUid: (submittedBy['uid'] as String?) ?? '',
      submittedByName: (submittedBy['name'] as String?) ?? 'Unknown',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
      staffNotes: (map['staffNotes'] as String?) ?? '',
      timeline: ((map['timeline'] as List<Object?>?) ?? <Object?>[])
          .whereType<Map<String, Object?>>()
          .map(StatusEvent.fromMap)
          .toList(),
    );
  }
}
