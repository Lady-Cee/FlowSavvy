import 'package:intl/intl.dart';

String getFormattedDate() {
  DateTime now = DateTime.now();
  return DateFormat('EEE. MMM dd, yyyy').format(now);
}