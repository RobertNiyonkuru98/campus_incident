/// The five incident categories from the brief.
enum ReportCategory { facilities, water, electricity, safety, sanitation }

extension ReportCategoryX on ReportCategory {
  String get label {
    switch (this) {
      case ReportCategory.facilities:
        return 'Facilities';
      case ReportCategory.water:
        return 'Water';
      case ReportCategory.electricity:
        return 'Electricity';
      case ReportCategory.safety:
        return 'Safety';
      case ReportCategory.sanitation:
        return 'Sanitation';
    }
  }

  /// The value stored in Firestore. Kept explicit so renaming an enum in Dart
  /// can never silently break data already in the database.
  String get firestoreValue {
    switch (this) {
      case ReportCategory.facilities:
        return 'facilities';
      case ReportCategory.water:
        return 'water';
      case ReportCategory.electricity:
        return 'electricity';
      case ReportCategory.safety:
        return 'safety';
      case ReportCategory.sanitation:
        return 'sanitation';
    }
  }
}

ReportCategory categoryFromValue(String? value) => ReportCategory.values
    .firstWhere((ReportCategory c) => c.firestoreValue == value,
        orElse: () => ReportCategory.facilities);

/// The three states a report moves through.
enum ReportStatus { submitted, inProgress, resolved }

extension ReportStatusX on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.resolved:
        return 'Resolved';
    }
  }

  String get firestoreValue {
    switch (this) {
      case ReportStatus.submitted:
        return 'submitted';
      case ReportStatus.inProgress:
        return 'inProgress';
      case ReportStatus.resolved:
        return 'resolved';
    }
  }
}

ReportStatus statusFromValue(String? value) => ReportStatus.values.firstWhere(
      (ReportStatus s) => s.firestoreValue == value,
      orElse: () => ReportStatus.submitted,
    );

/// 'student' can submit and read. 'staff' can additionally change status.
enum UserRole { student, staff }

extension UserRoleX on UserRole {
  String get label => this == UserRole.staff ? 'Staff Member' : 'Student';
  String get firestoreValue => this == UserRole.staff ? 'staff' : 'student';
}

UserRole roleFromValue(String? value) =>
    value == 'staff' ? UserRole.staff : UserRole.student;
