import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/tracker_data.dart';
import '../../domain/usecases/tracker_usecases.dart';

enum AppStatus { loading, onboarding, ready }

class AppState {
  const AppState({
    this.status = AppStatus.loading,
    this.themeMode = ThemeMode.dark,
  });

  final AppStatus status;
  final ThemeMode themeMode;

  AppState copyWith({
    AppStatus? status,
    ThemeMode? themeMode,
  }) {
    return AppState(
      status: status ?? this.status,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class AppCubit extends Cubit<AppState> {
  AppCubit(this.load, this.save) : super(const AppState());

  final LoadTrackerUseCase load;
  final SaveTrackerUseCase save;

  Future<void> initialize() async {
    final data = await load();

    emit(
      state.copyWith(
        status: data.nickname.trim().isEmpty
            ? AppStatus.onboarding
            : AppStatus.ready,
        themeMode: _theme(data.themeMode),
      ),
    );
  }

  ThemeMode _theme(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  Future<void> completeOnboarding() async {
    emit(state.copyWith(status: AppStatus.ready));
  }

  void resetToOnboarding() {
    emit(state.copyWith(status: AppStatus.onboarding));
  }

  Future<void> setTheme(
    TrackerData data,
    ThemeMode mode,
  ) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
      ThemeMode.dark => 'dark',
    };

    await save(data.copyWith(themeMode: value));

    emit(
      state.copyWith(themeMode: mode),
    );
  }
}