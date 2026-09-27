import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/tracker_data.dart';
import '../../domain/usecases/tracker_usecases.dart';

class TrackerState {
  const TrackerState({
    this.data,
    this.loading = true,
  });

  final TrackerData? data;
  final bool loading;

  TrackerState copyWith({
    TrackerData? data,
    bool? loading,
  }) {
    return TrackerState(
      data: data ?? this.data,
      loading: loading ?? this.loading,
    );
  }
}

class TrackerCubit extends Cubit<TrackerState> {
  TrackerCubit(
    this.load,
    this.save,
    this.toggle,
    this.updateActivities,
    this.updateNickname,
  ) : super(const TrackerState()) {
    initialize();
  }

  final LoadTrackerUseCase load;
  final SaveTrackerUseCase save;
  final ToggleCompletionUseCase toggle;
  final UpdateActivitiesUseCase updateActivities;
  final UpdateNicknameUseCase updateNickname;

  Future<void> initialize() async {
    final data = await load();
    emit(TrackerState(data: data, loading: false));
  }

  Future<void> saveProfile(String nickname) async {
    final data = state.data;
    if (data == null) return;
    final updated = data.copyWith(nickname: nickname.trim());
    await updateNickname(updated);
    emit(state.copyWith(data: updated));
  }

  Future<void> setActivities(List<Activity> activities) async {
    final data = state.data;
    if (data == null) return;
    final updated = data.copyWith(activities: activities);
    await updateActivities(updated);
    emit(state.copyWith(data: updated));
  }

  Future<void> toggleCompletion(String dateKey, String activityId) async {
    final data = state.data;
    if (data == null) return;
    final updated = await toggle(data, dateKey, activityId);
    emit(state.copyWith(data: updated));
  }

  Future<void> resetProgress() async {
    final data = state.data;
    if (data == null) return;
    final updated = data.copyWith(completions: {});
    await save(updated);
    emit(state.copyWith(data: updated));
  }
}
