import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tracker_model.dart';

class LocalStorageDataSource {
  static const _key = 'never_give_up_tracker_v1';

  Future<TrackerModel> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null || raw.isEmpty) {
      return const TrackerModel(
        nickname: '',
        activities: [],
        completions: {},
        themeMode: 'dark',
      );
    }

    try {
      return TrackerModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const TrackerModel(
        nickname: '',
        activities: [],
        completions: {},
        themeMode: 'dark',
      );
    }
  }

  Future<void> save(TrackerModel data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data.toJson()));
  }
}
