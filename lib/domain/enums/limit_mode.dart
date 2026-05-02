enum LimitMode {
  attemptsOnly,
  timeOnly,
  attemptsAndTime;

  String get label => switch (this) {
    LimitMode.attemptsOnly => 'Attempts Only',
    LimitMode.timeOnly => 'Time Only',
    LimitMode.attemptsAndTime => 'Attempts + Time',
  };
}
