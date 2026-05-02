import 'dart:ui';

class AppText {
  static bool get isKo =>
      PlatformDispatcher.instance.locale.languageCode == 'ko';

  static String get missionSetup => isKo ? '미션 설정' : 'Mission Setup';
  static String get setChallenge => isKo ? '도전 조건 설정' : 'Set Your Challenge';
  static String get difficulty => isKo ? '난이도' : 'Difficulty';
  static String get beginner => isKo ? '초급' : 'Beginner';
  static String get normal => isKo ? '중급' : 'Normal';
  static String get expert => isKo ? '고급' : 'Expert';
  static String get digits => isKo ? '자리' : 'Digits';
  static String get tries => isKo ? '회' : 'Tries';
  static String get noTimer => isKo ? '타이머 없음' : 'No Timer';
  static String get reward => isKo ? '보상' : 'Reward';
  static String get limitMode => isKo ? '제한 모드' : 'Limit Mode';
  static String get attemptsLimit => isKo ? '시도 제한' : 'Attempts Limit';
  static String get timeLimit => isKo ? '시간 제한' : 'Time Limit';
  static String get options => isKo ? '옵션' : 'Options';
  static String get sound => isKo ? '효과음' : 'Sound';
  static String get music => isKo ? '음악' : 'Music';
  static String get vibration => isKo ? '진동' : 'Vibration';
  static String get on => isKo ? '켜짐' : 'On';
  static String get off => isKo ? '꺼짐' : 'Off';
  static String get startMission => isKo ? '미션 시작' : 'Start Mission';
  static String get laterSettings => isKo
      ? '이 설정은 나중에 메뉴에서 바꿀 수 있습니다.'
      : 'You can change these settings later in the menu.';
  static String get checkTable => isKo ? '체크 테이블' : 'Check Table';
  static String get autoCheckTable => isKo ? '자동 체크 테이블' : 'Auto Check Table';
  static String get manualCheckTable =>
      isKo ? '수동 체크 테이블' : 'Manual Check Table';
  static String get left => isKo ? '남음' : 'Left';
  static String get time => isKo ? '시간' : 'Time';
  static String get tried => isKo ? '시도' : 'Tried';
  static String get delete => isKo ? '삭제' : 'Delete';
  static String get submit => isKo ? '제출' : 'Submit';
  static String get resume => isKo ? '계속' : 'Resume';
  static String get pause => isKo ? '일시정지' : 'Pause';
  static String get history => isKo ? '기록' : 'History';
  static String get noAttempts => isKo ? '아직 시도 기록이 없습니다.' : 'No attempts yet.';
  static String get records => isKo ? '기록' : 'Records';
  static String get settings => isKo ? '설정' : 'Settings';
  static String get tutorial => isKo ? '도움말' : 'Tutorial';
  static String get clear => isKo ? '삭제' : 'Clear';
  static String get noRecords => isKo ? '아직 저장된 기록이 없습니다.' : 'No records yet.';
  static String get recentPlays => isKo ? '최근 플레이' : 'Recent Plays';
  static String get fewestAttempts => isKo ? '최소 시도 기록' : 'Fewest Attempts';
  static String get fastestTime => isKo ? '최단 시간 기록' : 'Fastest Time';
  static String get win => isKo ? '성공' : 'Win';
  static String get tryAgain => isKo ? '다시 하기' : 'Try Again';
  static String get home => isKo ? '홈' : 'Home';
  static String get answer => isKo ? '정답' : 'Answer';
  static String get attempts => isKo ? '시도 횟수' : 'Attempts';
  static String get limit => isKo ? '제한' : 'Limit';
  static String get missionComplete => isKo ? '미션 완료.' : 'Mission complete.';
  static String get attemptsUsedUp =>
      isKo ? '시도 횟수를 모두 사용했습니다.' : 'Attempts used up. Try a fresh route.';
  static String get timeExpired =>
      isKo ? '시간이 종료되었습니다.' : 'Time expired. Try again with a sharper path.';
  static String get comingSoon => isKo ? '출시 준비 중입니다.' : 'Coming soon.';

  static String difficultyLabel(String name) {
    return switch (name) {
      'beginner' => beginner,
      'normal' => normal,
      'expert' => expert,
      _ => name,
    };
  }

  static String limitModeLabel(String name) {
    return switch (name) {
      'attemptsOnly' => isKo ? '시도 제한' : 'Attempts Only',
      'timeOnly' => isKo ? '시간 제한' : 'Time Only',
      'attemptsAndTime' => isKo ? '시도 + 시간 제한' : 'Attempts + Time',
      _ => name,
    };
  }
}
