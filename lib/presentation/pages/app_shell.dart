import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/app_cubit.dart';
import '../bloc/tracker_cubit.dart';
import 'home/home_page.dart';
import 'setup/setup_page.dart';
import 'splash/splash_page.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        switch (appState.status) {
          case AppStatus.loading:
            return const SplashPage();
          case AppStatus.onboarding:
            return const SetupPage();
          case AppStatus.ready:
            return const HomePage();
        }
      },
    );
  }
}
