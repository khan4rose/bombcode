import 'package:flutter/material.dart';

import '../../core/constants/app_text.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppText.settings),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: AppBackground(
        dim: true,
        lightText: true,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(r.c(18)),
            children: [
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: Text(AppText.isKo ? '언어' : 'Language'),
                subtitle: Text(
                  AppText.isKo
                      ? '휴대폰 언어에 따라 한글/영문 화면이 자동 선택됩니다.'
                      : 'Device language chooses Korean or English screens.',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.storage_rounded),
                title: Text(AppText.isKo ? '저장소' : 'Storage'),
                subtitle: Text(
                  AppText.isKo
                      ? '기록은 이 기기에만 저장됩니다.'
                      : 'Records are saved on this device.',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(AppText.isKo ? '버전' : 'Version'),
                subtitle: const Text('BoomCode MVP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
