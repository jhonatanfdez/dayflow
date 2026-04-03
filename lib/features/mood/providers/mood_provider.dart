import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_model.dart';

class MoodNotifier extends StateNotifier<MoodEntry?> {
  MoodNotifier() : super(null);

  void setMood(MoodType mood, {String? note}) {
    state = MoodEntry(
      mood: mood,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
      registeredAt: DateTime.now(),
    );
  }

  void clearMood() {
    state = null;
  }
}

final moodProvider = StateNotifierProvider<MoodNotifier, MoodEntry?>(
  (ref) => MoodNotifier(),
);
