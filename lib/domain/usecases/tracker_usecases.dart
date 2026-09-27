import '../entities/tracker_data.dart';
import '../repositories/tracker_repository.dart';

class LoadTrackerUseCase {
  const LoadTrackerUseCase(this.repository);
  final TrackerRepository repository;

  Future<TrackerData> call() => repository.load();
}

class SaveTrackerUseCase {
  const SaveTrackerUseCase(this.repository);
  final TrackerRepository repository;

  Future<void> call(TrackerData data) => repository.save(data);
}

class ToggleCompletionUseCase {
  const ToggleCompletionUseCase(this.repository);
  final TrackerRepository repository;

  Future<TrackerData> call(
    TrackerData data,
    String dateKey,
    String activityId,
  ) async {
    final completions = <String, Map<String, bool>>{
      for (final entry in data.completions.entries)
        entry.key: Map<String, bool>.from(entry.value),
    };

    final day = completions.putIfAbsent(dateKey, () => {});
    day[activityId] = !(day[activityId] ?? false);

    final updated = data.copyWith(completions: completions);
    await repository.save(updated);
    return updated;
  }
}

class UpdateActivitiesUseCase {
  const UpdateActivitiesUseCase(this.repository);
  final TrackerRepository repository;

  Future<void> call(TrackerData data) => repository.save(data);
}

class UpdateNicknameUseCase {
  const UpdateNicknameUseCase(this.repository);
  final TrackerRepository repository;

  Future<void> call(TrackerData data) => repository.save(data);
}
