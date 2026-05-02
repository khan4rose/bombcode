enum DigitMark {
  unknown,
  possible,
  impossible,
  accessCandidate,
  traceCandidate;

  String get label => switch (this) {
    DigitMark.unknown => '?',
    DigitMark.possible => 'OK',
    DigitMark.impossible => 'X',
    DigitMark.accessCandidate => 'A',
    DigitMark.traceCandidate => 'T',
  };

  DigitMark get next => switch (this) {
    DigitMark.unknown => DigitMark.possible,
    DigitMark.possible => DigitMark.impossible,
    DigitMark.impossible => DigitMark.accessCandidate,
    DigitMark.accessCandidate => DigitMark.traceCandidate,
    DigitMark.traceCandidate => DigitMark.unknown,
  };
}
