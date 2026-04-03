import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';

class HydrationNotifier extends StateNotifier<int> {
  HydrationNotifier() : super(0) {
    _loadHydration();
  }

  Future<void> _loadHydration() async {
    final glasses = await DatabaseHelper.instance.getHydrationForToday();
    state = glasses;
  }

  Future<void> addGlass() async {
    if (state < 8) {
      state = state + 1;
      await DatabaseHelper.instance.upsertHydration(state);
    }
  }

  Future<void> removeGlass() async {
    if (state > 0) {
      state = state - 1;
      await DatabaseHelper.instance.upsertHydration(state);
    }
  }

  Future<void> reset() async {
    state = 0;
    await DatabaseHelper.instance.upsertHydration(0);
  }
}

final hydrationProvider = StateNotifierProvider<HydrationNotifier, int>(
  (ref) => HydrationNotifier(),
);
