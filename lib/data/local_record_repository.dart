import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/game_record.dart';
import 'record_repository.dart';

class LocalRecordRepository implements RecordRepository {
  static const _key = 'boomcode.records';

  @override
  Future<List<GameRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    return raw
        .map(
          (entry) =>
              GameRecord.fromJson(jsonDecode(entry) as Map<String, dynamic>),
        )
        .toList()
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
  }

  @override
  Future<void> saveRecord(GameRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = prefs.getStringList(_key) ?? <String>[];
    records.insert(0, jsonEncode(record.toJson()));
    await prefs.setStringList(_key, records.take(50).toList());
  }

  @override
  Future<void> clearRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
