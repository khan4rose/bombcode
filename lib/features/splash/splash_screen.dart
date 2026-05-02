import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    _showHomeAfterImageIsReady();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Image.asset(
          _assetFor(context),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            return const ColoredBox(color: Colors.black);
          },
        ),
      ),
    );
  }

  Future<void> _showHomeAfterImageIsReady() async {
    try {
      await precacheImage(AssetImage(_assetFor(context)), context);
    } catch (_) {
      // Keep the app moving even if the splash asset is missing.
    }
    if (!mounted) {
      return;
    }
    _timer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  String _assetFor(BuildContext context) {
    final locale = PlatformDispatcher.instance.locale;
    return locale.languageCode == 'ko'
        ? 'assets/splash/main_kor.png'
        : 'assets/splash/main_eng.png';
  }
}
