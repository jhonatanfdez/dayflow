import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../models/mood_model.dart';

class MoodNotifier extends StateNotifier<MoodEntry?> {
  MoodNotifier() : super(null) {
    _loadMood();
  }

  Future<void> _loadMood() async {
    final row = await DatabaseHelper.instance.getMoodForToday();
    if (row == null) return;
    state = MoodEntry(
      mood: MoodType.values.byName(row['moodType'] as String),
      note: row['note'] as String?,
      registeredAt: DateTime.parse(row['registeredAt'] as String),
    );
  }

  Future<void> setMood(MoodType mood, {String? note}) async {
    final trimmedNote = note?.trim().isEmpty == true ? null : note?.trim();
    final entry = MoodEntry(
      mood: mood,
      note: trimmedNote,
      registeredAt: DateTime.now(),
    );
    await DatabaseHelper.instance.upsertMood({
      'moodType': mood.name,
      'note': trimmedNote,
      'registeredAt': entry.registeredAt.toIso8601String(),
    });
    state = entry;
  }

  Future<void> clearMood() async {
    await DatabaseHelper.instance.deleteMoodForToday();
    state = null;
  }
}

final moodProvider = StateNotifierProvider<MoodNotifier, MoodEntry?>(
  (ref) => MoodNotifier(),
);
