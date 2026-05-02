import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text.dart';
import '../../../domain/enums/digit_mark.dart';
import '../game_controller.dart';

class CheckTable extends StatelessWidget {
  final GameController controller;

  const CheckTable({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppText.checkTable, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.5,
          children: [
            for (var digit = 0; digit <= 9; digit++)
              InkWell(
                onTap: controller.config?.autoCheckTable == true
                    ? null
                    : () => controller.markDigit(digit),
                borderRadius: BorderRadius.circular(8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _color(controller.digitMarks[digit]!),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Center(
                    child: Text(
                      '$digit  ${controller.digitMarks[digit]!.label}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Color _color(DigitMark mark) {
    return switch (mark) {
      DigitMark.unknown => Colors.white,
      DigitMark.possible => AppColors.markPossible,
      DigitMark.impossible => AppColors.markNo,
      DigitMark.accessCandidate => AppColors.markAccess,
      DigitMark.traceCandidate => AppColors.markTrace,
    };
  }
}
