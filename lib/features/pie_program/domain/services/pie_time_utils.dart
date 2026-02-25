class PieTimeUtils {
  static const int minutesInDay = 24 * 60;

  static DateTime dateOnly(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  static DateTime fromMinutes(DateTime day, int minute) {
    final normalized = minute.clamp(0, minutesInDay);
    final base = dateOnly(day);
    return base.add(Duration(minutes: normalized));
  }

  static int toMinutes(DateTime value) {
    final local = value.toLocal();
    return local.hour * 60 + local.minute;
  }

  static String dateKey(DateTime date) {
    final local = dateOnly(date);
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  static int minutesUntil(DateTime from, DateTime to) {
    if (to.isBefore(from)) {
      return 0;
    }
    return to.difference(from).inMinutes;
  }
}
