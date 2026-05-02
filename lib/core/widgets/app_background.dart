import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final bool dim;
  final bool lightText;

  const AppBackground({
    super.key,
    required this.child,
    this.dim = false,
    this.lightText = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = lightText
        ? Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                surface: const Color(0xFF202428),
                onSurface: Colors.white,
                primary: Colors.redAccent,
              ),
              textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
              listTileTheme: const ListTileThemeData(
                iconColor: Colors.white,
                textColor: Colors.white,
              ),
              radioTheme: RadioThemeData(
                fillColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.selected)
                      ? Colors.redAccent
                      : Colors.white70;
                }),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.selected)
                      ? Colors.redAccent
                      : Colors.white70;
                }),
              ),
            ),
            child: child,
          )
        : child;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/menu/background.png',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            return const ColoredBox(color: Color(0xFF15191D));
          },
        ),
        if (dim) ColoredBox(color: Colors.black.withValues(alpha: 0.46)),
        content,
      ],
    );
  }
}
