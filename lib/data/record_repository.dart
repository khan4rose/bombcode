import '../domain/models/game_record.dart';

abstract class RecordRepository {
  Future<List<GameRecord>> loadRecords();
  Future<void> saveRecord(GameRecord record);
  Future<void> clearRecords();
}
