import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../bloc/app_cubit.dart';
import '../../bloc/tracker_cubit.dart';
import '../setup/activity_manager_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.onBack});

  final VoidCallback onBack;

  Future<void> _nickname(BuildContext context) async {
    final tracker = context.read<TrackerCubit>();
    final controller = TextEditingController(
      text: tracker.state.data?.nickname ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change nickname'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nickname'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await tracker.saveProfile(controller.text);
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackerCubit, TrackerState>(
      builder: (context, trackerState) {
        final data = trackerState.data;
        if (data == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              _group(
                context,
                'PROFILE',
                [
                  _tile(
                    context,
                    icon: Icons.person_outline_rounded,
                    title: 'Nickname',
                    subtitle: data.nickname,
                    onTap: () => _nickname(context),
                  ),
                  _tile(
                    context,
                    icon: Icons.checklist_rounded,
                    title: 'Manage activities',
                    subtitle: '${data.activities.length} activities',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ActivityManagerPage(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _group(
                context,
                'APPEARANCE',
                [
                  BlocBuilder<AppCubit, AppState>(
                    builder: (context, appState) {
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 15),
                        leading: const Icon(Icons.palette_outlined),
                        title: const Text(
                          'Theme',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          switch (appState.themeMode) {
                            ThemeMode.light => 'Light',
                            ThemeMode.dark => 'Dark',
                            ThemeMode.system => 'System default',
                          },
                        ),
                        trailing: DropdownButton<ThemeMode>(
                          value: appState.themeMode,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text('System'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text('Light'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text('Dark'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              context.read<AppCubit>().setTheme(data, value);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _group(
                context,
                'DATA',
                [
                  _tile(
                    context,
                    icon: Icons.restart_alt_rounded,
                    title: 'Start fresh',
                    subtitle: 'Clear all app data and start again',
                    danger: false,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Start fresh?'),
                          content: const Text(
                            'Your nickname, activities, checkmarks and progress history will be cleared. You will start again from the beginning.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Start fresh'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        await context.read<TrackerCubit>().resetProgress();
                        context.read<AppCubit>().resetToOnboarding();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    const Text(
                      'NEVER GIVE UP',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Small steps. Stronger you.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: .45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _group(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: .5),
          ),
        ),
        const SizedBox(height: 9),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      leading: Icon(
        icon,
        color: danger ? AppColors.danger : null,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
