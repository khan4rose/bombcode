enum Difficulty {
  beginner,
  normal,
  expert;

  String get label => switch (this) {
    Difficulty.beginner => 'Beginner',
    Difficulty.normal => 'Normal',
    Difficulty.expert => 'Expert',
  };
}
