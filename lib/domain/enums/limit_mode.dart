enum LimitMode {
  none,
  attemptsOnly,
  timeOnly,
  attemptsAndTime;

  String get label => switch (this) {
    LimitMode.none => 'No Limit',
    LimitMode.attemptsOnly => 'Attempts Only',
    LimitMode.timeOnly => 'Time Only',
    LimitMode.attemptsAndTime => 'Attempts + Time',
  };
}
