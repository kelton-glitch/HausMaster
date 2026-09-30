import 'package:intl/intl.dart';

/// XAF has no minor unit: whole numbers with locale-aware thousands separators
/// (NFR-11), e.g. `85 000 XAF` (fr) / `85,000 XAF` (en).
String formatXaf(num amount, String localeName) =>
    '${NumberFormat.decimalPattern(localeName).format(amount)} XAF';

/// "Ada Njoh" -> "AN" (up to two initials).
String initialsOf(String fullName) {
  final parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty);
  return parts.take(2).map((p) => p[0]).join().toUpperCase();
}
