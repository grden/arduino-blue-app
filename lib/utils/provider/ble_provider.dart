import 'package:riverpod/riverpod.dart';

class BLENotifier extends StateNotifier<List<int>> {
  BLENotifier() : super([]);

  void setBLE(List<int> data) {
    state = data;
  }
}

final gpsProvider =
    StateNotifierProvider<BLENotifier, List<int>>((ref) => BLENotifier());

final tempProvider =
    StateNotifierProvider<BLENotifier, List<int>>((ref) => BLENotifier());

final bpmProvider =
    StateNotifierProvider<BLENotifier, List<int>>((ref) => BLENotifier());
