import 'package:flutter/material.dart';

import '../../../core/constants/app_text.dart';
import '../../../domain/models/guess_record.dart';

class GuessHistoryList extends StatelessWidget {
  final List<GuessRecord> history;

  const GuessHistoryList({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(child: Text(AppText.noAttempts));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppText.history, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final record in history)
          Card(
            color: Colors.black.withValues(alpha: 0.48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.white24),
            ),
            child: ListTile(
              leading: CircleAvatar(child: Text('${record.attemptNumber}')),
              title: Text(
                record.guess.join(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                'Access ${record.result.access}  |  Trace ${record.result.trace}',
              ),
            ),
          ),
      ],
    );
  }
}
