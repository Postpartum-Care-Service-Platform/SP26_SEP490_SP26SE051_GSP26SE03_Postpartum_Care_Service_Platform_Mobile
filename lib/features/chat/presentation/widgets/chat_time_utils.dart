import 'package:intl/intl.dart';

String formatChatTime(DateTime time) {
  final now = DateTime.now();
  if (now.difference(time).inDays == 0) {
    return DateFormat('HH:mm').format(time.toLocal());
  }
  return DateFormat('dd/MM').format(time.toLocal());
}

