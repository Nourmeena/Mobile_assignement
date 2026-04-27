Duration calculateRemainingTime(String dueDateString) {
  DateTime dueDate = DateTime.parse(dueDateString);

  DateTime now = DateTime.now();
  now = DateTime(now.year, now.month, now.day);

  return dueDate.difference(now);
}

String formatRemainingTime(Duration duration) {
  if (duration.isNegative) {
    return "Deadline passed";
  }

  if (duration.inDays > 0) {
    return "${duration.inDays} days remaining";
  } else if (duration.inHours > 0) {
    return "${duration.inHours} hours remaining";
  } else {
    return "Due today";
  }
}
