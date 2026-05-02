import 'package:flutter/material.dart';

import '../../../core/constants/app_text.dart';

class NumberKeypad extends StatelessWidget {
  final Set<int> usedDigits;
  final ValueChanged<int> onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onSubmit;

  const NumberKeypad({
    super.key,
    required this.usedDigits,
    required this.onDigit,
    required this.onDelete,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.15,
          children: [
            for (var digit = 0; digit <= 9; digit++)
              FilledButton.tonal(
                onPressed: usedDigits.contains(digit)
                    ? null
                    : () => onDigit(digit),
                child: Text(
                  '$digit',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.backspace_rounded),
                label: Text(AppText.delete),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.check_rounded),
                label: Text(AppText.submit),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
