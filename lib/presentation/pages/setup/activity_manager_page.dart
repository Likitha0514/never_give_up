import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/activity.dart';
import '../../bloc/tracker_cubit.dart';

class ActivityManagerPage extends StatelessWidget {
  const ActivityManagerPage({super.key});

  Future<void> _edit(BuildContext context, Activity? existing) async {
    final name = TextEditingController(text: existing?.name ?? '');
    var emoji = existing?.emoji ?? '✓';
    final emojis = ['✓', '🏃', '📖', '📚', '💧', '🧘', '💪', '🎯', '😴', '✍️'];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'Add activity' : 'Edit activity'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Activity name',
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 44,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (int index = 0;
                              index < emojis.length;
                              index++) ...[
                            InkWell(
                              onTap: () =>
                                  setDialogState(() => emoji = emojis[index]),
                              child: Container(
                                width: 40,
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: emoji == emojis[index]
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(emojis[index]),
                              ),
                            ),
                            if (index != emojis.length - 1)
                              const SizedBox(width: 5),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final value = name.text.trim();
                    if (value.isEmpty) return;

                    final tracker = context.read<TrackerCubit>();
                    final current = tracker.state.data!;
                    final list = [...current.activities];

                    if (existing == null) {
                      list.add(
                        Activity(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          name: value,
                          emoji: emoji,
                          active: true,
                          createdAt: DateTime.now(),
                        ),
                      );
                    } else {
                      final index = list.indexWhere((e) => e.id == existing.id);
                      if (index != -1) {
                        list[index] = list[index].copyWith(
                          name: value,
                          emoji: emoji,
                        );
                      }
                    }

                    tracker.setActivities(list);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    name.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackerCubit, TrackerState>(
      builder: (context, state) {
        final activities = state.data?.activities ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Activities',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _edit(context, null),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add activity'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            children: [
              Text(
                'These are the actions you are choosing to repeat.',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: .55),
                ),
              ),
              const SizedBox(height: 18),
              ...activities.map(
                (activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Dismissible(
                    key: ValueKey(activity.id),
                    background: Container(
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 22),
                      child: const Icon(
                        Icons.archive_outlined,
                        color: AppColors.danger,
                      ),
                    ),
                    confirmDismiss: (_) async {
                      final tracker = context.read<TrackerCubit>();
                      final list = tracker.state.data!.activities
                          .map(
                            (item) => item.id == activity.id
                                ? item.copyWith(active: false)
                                : item,
                          )
                          .toList();
                      await tracker.setActivities(list);
                      return false;
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      leading: Text(
                        activity.emoji,
                        style: const TextStyle(fontSize: 23),
                      ),
                      title: Text(
                        activity.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        activity.active ? 'Active' : 'Archived',
                        style: TextStyle(
                          color: activity.active
                              ? AppColors.primary
                              : AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _edit(context, activity),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          Switch(
                            value: activity.active,
                            onChanged: (value) {
                              final tracker = context.read<TrackerCubit>();
                              final list = tracker.state.data!.activities
                                  .map(
                                    (item) => item.id == activity.id
                                        ? item.copyWith(active: value)
                                        : item,
                                  )
                                  .toList();
                              tracker.setActivities(list);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
