import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart' as dates;
import '../../../domain/entities/activity.dart';
import '../../bloc/tracker_cubit.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key, required this.onBack});

  final VoidCallback onBack;

  List<DateTime> get days {
    final today = DateTime.now();
    return List.generate(
      30,
      (i) => DateTime(today.year, today.month, today.day - 29 + i),
    );
  }

  double activityProgress(
    TrackerState state,
    Activity activity,
  ) {
    final d = days;
    if (d.isEmpty) return 0;
    final done = d
        .where(
          (date) =>
              state.data!.completions[dates.dayKey(date)]?[activity.id] == true,
        )
        .length;
    return done / d.length;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackerCubit, TrackerState>(
      builder: (context, state) {
        final data = state.data;
        if (data == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final active = data.activities.where((e) => e.active).toList();
        final totalCells = active.length * days.length;
        final completedCells = active.fold<int>(
          0,
          (sum, activity) =>
              sum +
              days
                  .where(
                    (day) =>
                        data.completions[dates.dayKey(day)]?[activity.id] ==
                        true,
                  )
                  .length,
        );
        final overall = totalCells == 0
            ? 0.0
            : completedCells.toDouble() / totalCells.toDouble();
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: const Text(
              'Your Progress',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            children: [
              _hero(context, overall),
              const SizedBox(height: 18),
              _sectionTitle('CONSISTENCY — LAST 30 DAYS'),
              const SizedBox(height: 10),
              _heatmap(context, data, active),
              const SizedBox(height: 24),
              _sectionTitle('ACTIVITY PERFORMANCE'),
              const SizedBox(height: 10),
              ...active.map(
                (activity) => _activityCard(
                  context,
                  activity,
                  activityProgress(state, activity),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('THIS MONTH'),
              const SizedBox(height: 10),
              _dailyBars(context, data, active),
            ],
          ),
        );
      },
    );
  }

  Widget _hero(BuildContext context, double overall) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1C2415), Color(0xFF11141C)],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: .18)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: overall,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withValues(alpha: .07),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
                Text(
                  '${(overall * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OVERALL CONSISTENCY',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Every checkbox is a small promise kept to yourself.',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.6,
      ),
    );
  }

  Widget _heatmap(
    BuildContext context,
    dynamic data,
    List<Activity> active,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: days.map((day) {
          final total = active.length;
          final done = active
              .where(
                (activity) =>
                    data.completions[dates.dayKey(day)]?[activity.id] == true,
              )
              .length;
          final value = total == 0 ? 0.0 : done / total;

          return Tooltip(
            message:
                '${DateFormat('d MMM').format(day)} • ${(value * 100).round()}%',
            child: Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: value == 0
                    ? Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: .06)
                    : AppColors.primary.withValues(
                        alpha: .15 + value * .85,
                      ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _activityCard(
    BuildContext context,
    Activity activity,
    double value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(activity.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    activity.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${(value * 100).round()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: .07),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dailyBars(
    BuildContext context,
    dynamic data,
    List<Activity> active,
  ) {
    return Container(
      height: 170,
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: days.take(14).map((day) {
          final total = active.length;
          final done = active
              .where(
                (activity) =>
                    data.completions[dates.dayKey(day)]?[activity.id] == true,
              )
              .length;
          final value = total == 0 ? 0.0 : done / total;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: max(0.04, value).toDouble(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(
                              alpha: .35 + value * .65,
                            ),
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 9,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: .5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
