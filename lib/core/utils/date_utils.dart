import 'package:intl/intl.dart';

String dayKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

String shortDate(DateTime date) => DateFormat('d').format(date);

String monthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);

String weekdayLetter(DateTime date) => DateFormat('E').format(date)[0];

String greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}
