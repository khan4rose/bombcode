import 'package:flutter/material.dart';

import '../../../core/constants/app_text.dart';
import '../../../core/utils/timer_formatter.dart';
import '../game_controller.dart';

class LimitStatusBar extends StatelessWidget {
  final GameController controller;

  const LimitStatusBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    if (controller.usesAttempts) {
      items.add(
        _StatusItem(
          icon: Icons.flag_rounded,
          label: AppText.left,
          value: '${controller.remainingAttempts}',
        ),
      );
    }
    if (controller.usesTime) {
      items.add(
        _StatusItem(
          icon: Icons.timer_rounded,
          label: AppText.time,
          value: formatSeconds(controller.remainingSeconds ?? 0),
        ),
      );
    }
    items.add(
      _StatusItem(
        icon: Icons.history_rounded,
        label: AppText.tried,
        value: '${controller.history.length}',
      ),
    );

    return Row(children: [for (final item in items) Expanded(child: item)]);
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.redAccent),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          Text(label),
        ],
      ),
    );
  }
}
