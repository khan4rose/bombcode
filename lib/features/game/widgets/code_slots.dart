import 'package:flutter/material.dart';

class CodeSlots extends StatelessWidget {
  final int length;
  final List<int> digits;

  const CodeSlots({super.key, required this.length, required this.digits});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < length; index++)
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Text(
                  index < digits.length ? '${digits[index]}' : '',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
