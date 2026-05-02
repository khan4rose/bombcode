import 'package:flutter/material.dart';

import '../../core/constants/app_text.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_background.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final pages = AppText.isKo
        ? const [
            ('목표', '숨겨진 숫자 코드를 찾으세요. 숫자는 중복되지 않으며 0도 첫 자리에 올 수 있습니다.'),
            ('Access', 'Access는 숫자와 위치가 모두 맞았다는 뜻입니다.'),
            ('Trace', 'Trace는 숫자는 코드 안에 있지만 위치가 다르다는 뜻입니다.'),
            ('기록', '시도 기록의 힌트를 보고 다음 입력을 좁혀가세요.'),
            ('제한', '미션 시작 전에 시도 제한, 시간 제한, 또는 둘 다 선택할 수 있습니다.'),
          ]
        : const [
            (
              'Goal',
              'Find the hidden code. Digits are unique, and 0 can be first.',
            ),
            (
              'Access',
              'Access means a digit is correct and in the correct position.',
            ),
            (
              'Trace',
              'Trace means a digit exists in the code but sits in another position.',
            ),
            (
              'History',
              'Use each clue in the history list to narrow your next guess.',
            ),
            (
              'Limits',
              'Choose attempts, time, or both before starting a mission.',
            ),
          ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppText.tutorial),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: AppBackground(
        dim: true,
        lightText: true,
        child: PageView(
          children: [
            for (final page in pages)
              Padding(
                padding: EdgeInsets.all(r.c(24)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      page.$1,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: r.c(22)),
                    Text(
                      page.$2,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
