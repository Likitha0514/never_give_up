import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/local_storage_datasource.dart';
import 'data/repositories/tracker_repository_impl.dart';
import 'domain/usecases/tracker_usecases.dart';
import 'presentation/bloc/app_cubit.dart';
import 'presentation/bloc/tracker_cubit.dart';
import 'presentation/pages/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = LocalStorageDataSource();
  final repository = TrackerRepositoryImpl(storage);
  final load = LoadTrackerUseCase(repository);
  final save = SaveTrackerUseCase(repository);
  final toggle = ToggleCompletionUseCase(repository);
  final updateActivities = UpdateActivitiesUseCase(repository);
  final updateNickname = UpdateNicknameUseCase(repository);

  runApp(
    NeverGiveUpApp(
      appCubit: AppCubit(load, save),
      trackerCubit: TrackerCubit(
        load,
        save,
        toggle,
        updateActivities,
        updateNickname,
      ),
    ),
  );
}

class NeverGiveUpApp extends StatelessWidget {
  const NeverGiveUpApp({
    super.key,
    required this.appCubit,
    required this.trackerCubit,
  });

  final AppCubit appCubit;
  final TrackerCubit trackerCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: appCubit),
        BlocProvider.value(value: trackerCubit),
      ],
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Never Give Up',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.themeMode,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
