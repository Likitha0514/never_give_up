import '../../domain/entities/tracker_data.dart';
import 'activity_model.dart';

class TrackerModel extends TrackerData {
  const TrackerModel({
    required super.nickname,
    required super.activities,
    required super.completions,
    required super.themeMode,
  });

  factory TrackerModel.fromJson(Map<String, dynamic> json) {
    final rawActivities = (json['activities'] as List<dynamic>? ?? []);
    final rawCompletions =
        (json['completions'] as Map<String, dynamic>? ?? {});

    return TrackerModel(
      nickname: json['nickname'] as String? ?? '',
      activities: rawActivities
          .map((e) => ActivityModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      completions: {
        for (final entry in rawCompletions.entries)
          entry.key: Map<String, bool>.from(
            (entry.value as Map<String, dynamic>),
          ),
      },
      themeMode: json['themeMode'] as String? ?? 'dark',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'activities': activities
          .map(
            (activity) => ActivityModel(
              id: activity.id,
              name: activity.name,
              emoji: activity.emoji,
              active: activity.active,
              createdAt: activity.createdAt,
            ).toJson(),
          )
          .toList(),
      'completions': completions,
      'themeMode': themeMode,
    };
  }
}
