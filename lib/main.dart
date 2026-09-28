import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/local_storage_datasource.dart';
import 'data/repositories/tracker_repository_impl.dart';
import 'domain/usecases/tracker_usecases.dart';
import 'presentation/bloc/app_cubit.dart';
import 'presentation/bloc/tracker_cubit.dart';
import 'presentation/pages/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = LocalStorageDataSource();
  final repository = TrackerRepositoryImpl(storage);

  final load = LoadTrackerUseCase(repository);
  final save = SaveTrackerUseCase(repository);
  final toggle = ToggleCompletionUseCase(repository);
  final updateActivities = UpdateActivitiesUseCase(repository);
  final updateNickname = UpdateNicknameUseCase(repository);

  final appCubit = AppCubit(load, save);

  final trackerCubit = TrackerCubit(
    load,
    save,
    toggle,
    updateActivities,
    updateNickname,
  );

  runApp(
    NeverGiveUpApp(
      appCubit: appCubit,
      trackerCubit: trackerCubit,
    ),
  );
}

class NeverGiveUpApp extends StatefulWidget {
  const NeverGiveUpApp({
    super.key,
    required this.appCubit,
    required this.trackerCubit,
  });

  final AppCubit appCubit;
  final TrackerCubit trackerCubit;

  @override
  State<NeverGiveUpApp> createState() => _NeverGiveUpAppState();
}

class _NeverGiveUpAppState extends State<NeverGiveUpApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.appCubit.initialize();
      widget.trackerCubit.initialize();
    });
  }

  @override
  void dispose() {
    widget.appCubit.close();
    widget.trackerCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.appCubit),
        BlocProvider.value(value: widget.trackerCubit),
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