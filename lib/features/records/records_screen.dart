import 'package:flutter/material.dart';

import '../../core/constants/app_text.dart';
import '../../core/utils/timer_formatter.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_background.dart';
import '../../data/local_record_repository.dart';
import '../../domain/models/game_record.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final repository = LocalRecordRepository();
  late Future<List<GameRecord>> records = repository.loadRecords();

  Future<void> _clear() async {
    await repository.clearRecords();
    setState(() => records = repository.loadRecords());
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppText.records),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: AppText.clear,
            onPressed: _clear,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: AppBackground(
        dim: true,
        lightText: true,
        child: FutureBuilder<List<GameRecord>>(
          future: records,
          builder: (context, snapshot) {
            final data = snapshot.data ?? const <GameRecord>[];
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (data.isEmpty) {
              return Center(child: Text(AppText.noRecords));
            }
            final wins = data.where((record) => record.success).toList();
            final bestAttempts = [...wins]
              ..sort((a, b) => a.attemptsUsed.compareTo(b.attemptsUsed));
            final bestTime = [...wins]
              ..sort((a, b) => a.elapsedSeconds.compareTo(b.elapsedSeconds));

            return ListView(
              padding: EdgeInsets.all(r.c(14)),
              children: [
                if (bestAttempts.isNotEmpty)
                  _BestTile(
                    title: AppText.fewestAttempts,
                    value: '${bestAttempts.first.attemptsUsed}',
                    record: bestAttempts.first,
                  ),
                if (bestTime.isNotEmpty)
                  _BestTile(
                    title: AppText.fastestTime,
                    value: formatSeconds(bestTime.first.elapsedSeconds),
                    record: bestTime.first,
                  ),
                const SizedBox(height: 12),
                Text(
                  AppText.recentPlays,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final record in data)
                  Card(
                    color: Colors.black.withValues(alpha: 0.48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.white24),
                    ),
                    child: ListTile(
                      leading: Icon(
                        record.success
                            ? Icons.verified_rounded
                            : Icons.lock_rounded,
                      ),
                      title: Text(
                        '${AppText.difficultyLabel(record.difficulty.name)} / ${AppText.limitModeLabel(record.limitMode.name)}',
                      ),
                      subtitle: Text(
                        '${record.attemptsUsed} ${AppText.tries}  |  ${formatSeconds(record.elapsedSeconds)}',
                      ),
                      trailing: Text(
                        record.success ? AppText.win : AppText.tryAgain,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BestTile extends StatelessWidget {
  final String title;
  final String value;
  final GameRecord record;

  const _BestTile({
    required this.title,
    required this.value,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withValues(alpha: 0.48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.white24),
      ),
      child: ListTile(
        leading: const Icon(Icons.workspace_premium_rounded),
        title: Text(title),
        subtitle: Text(
          '${AppText.difficultyLabel(record.difficulty.name)} / ${AppText.limitModeLabel(record.limitMode.name)}',
        ),
        trailing: Text(value, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}
