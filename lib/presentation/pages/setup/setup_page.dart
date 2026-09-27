import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/logo/never_give_up_logo.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glow_button.dart';
import '../../../domain/entities/activity.dart';
import '../../bloc/app_cubit.dart';
import '../../bloc/tracker_cubit.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final nickname = TextEditingController();
  final activities = <Activity>[];
  final activityName = TextEditingController();
  String selectedEmoji = '✓';

  final emojis = ['✓', '🏃', '📖', '📚', '💧', '🧘', '💪', '🎯', '😴', '✍️'];

  @override
  void dispose() {
    nickname.dispose();
    activityName.dispose();
    super.dispose();
  }

  void addActivity() {
    final name = activityName.text.trim();
    if (name.isEmpty) return;

    setState(() {
      activities.add(
        Activity(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: name,
          emoji: selectedEmoji,
          active: true,
          createdAt: DateTime.now(),
        ),
      );
      activityName.clear();
    });
  }

  Future<void> finish() async {
    if (nickname.text.trim().isEmpty) return;
    if (activities.isEmpty) {
      activities.add(
        Activity(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: 'Exercise',
          emoji: '🏃',
          active: true,
          createdAt: DateTime.now(),
        ),
      );
    }

    final tracker = context.read<TrackerCubit>();
    await tracker.saveProfile(nickname.text);
    await tracker.setActivities(activities);
    if (!mounted) return;
    await context.read<AppCubit>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
          children: [
            const Center(child: NeverGiveUpLogo(showTagline: false)),
            const SizedBox(height: 38),
            Text(
              'Let’s build your routine.',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.7,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'A few simple actions, repeated consistently, can change a lot.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .58),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 26),
            Text(
              'YOUR NICKNAME',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .55),
              ),
            ),
            const SizedBox(height: 9),
            TextField(
              controller: nickname,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'What should we call you?',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'YOUR ACTIVITIES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .55),
                    ),
                  ),
                ),
                Text(
                  '${activities.length} added',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...activities.map(
              (activity) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  tileColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: Text(activity.emoji, style: const TextStyle(fontSize: 21)),
                  title: Text(
                    activity.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: IconButton(
                    onPressed: () => setState(
                      () => activities.removeWhere((e) => e.id == activity.id),
                    ),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
                color: Theme.of(context).cardColor,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: activityName,
                    onSubmitted: (_) => addActivity(),
                    decoration: const InputDecoration(
                      hintText: 'Add an activity',
                      prefixIcon: Icon(Icons.add_task_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: emojis.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 7),
                      itemBuilder: (context, index) {
                        final emoji = emojis[index];
                        final selected = emoji == selectedEmoji;
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => setState(() => selectedEmoji = emoji),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: selected
                                  ? AppColors.primary.withValues(alpha: .18)
                                  : Theme.of(context).colorScheme.surface,
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(emoji, style: const TextStyle(fontSize: 19)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: addActivity,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add activity'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            GlowButton(
              label: 'Start my journey',
              icon: Icons.arrow_forward_rounded,
              onPressed: finish,
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                DateFormat('EEEE, d MMMM').format(DateTime.now()),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .45),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
