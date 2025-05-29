

DateTime getAdjustedDate(DateTime input) {
  if (input.hour >= 12) {
    return DateTime(input.year, input.month, input.day);
  } else {
    final previousDay = input.subtract(Duration(days: 1));
    return DateTime(previousDay.year, previousDay.month, previousDay.day);
  }
}
