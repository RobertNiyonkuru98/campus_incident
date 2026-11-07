import 'package:intl/intl.dart';

/// Date helpers, kept out of widgets so they can be reused and reasoned about.
class Fmt {
  const Fmt._();

  static String shortDate(DateTime? value) {
    if (value == null) return 'Just now';
    return DateFormat('d MMM yyyy').format(value);
  }

  static String dateTime(DateTime? value) {
    if (value == null) return 'Pending';
    return DateFormat("d MMM yyyy 'at' h:mm a").format(value);
  }

  /// "2 hours ago", "3 days ago". Deliberately simple and dependency-free.
  static String timeAgo(DateTime? value) {
    if (value == null) return 'Just now';
    final Duration diff = DateTime.now().difference(value);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 30) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    return shortDate(value);
  }
}
