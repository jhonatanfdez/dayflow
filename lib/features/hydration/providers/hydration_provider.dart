import 'package:flutter_riverpod/flutter_riverpod.dart';

class HydrationNotifier extends StateNotifier<int> {
  HydrationNotifier() : super(0);

  void addGlass() {
    if (state < 8) state = state + 1;
  }

  void removeGlass() {
    if (state > 0) state = state - 1;
  }

  void reset() {
    state = 0;
  }
}

final hydrationProvider = StateNotifierProvider<HydrationNotifier, int>(
  (ref) => HydrationNotifier(),
);
