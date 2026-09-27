import 'activity.dart';

class TrackerData {
  const TrackerData({
    required this.nickname,
    required this.activities,
    required this.completions,
    required this.themeMode,
  });

  final String nickname;
  final List<Activity> activities;

  /// date key -> activity id -> completed
  final Map<String, Map<String, bool>> completions;

  final String themeMode;

  TrackerData copyWith({
    String? nickname,
    List<Activity>? activities,
    Map<String, Map<String, bool>>? completions,
    String? themeMode,
  }) {
    return TrackerData(
      nickname: nickname ?? this.nickname,
      activities: activities ?? this.activities,
      completions: completions ?? this.completions,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
