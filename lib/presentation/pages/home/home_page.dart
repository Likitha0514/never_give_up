import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart' as dates;
import '../../../core/utils/motivation.dart';
import '../../../domain/entities/activity.dart';
import '../../bloc/tracker_cubit.dart';
import '../progress/progress_page.dart';
import '../settings/settings_page.dart';
import '../setup/activity_manager_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final horizontalController = ScrollController();
  final screenshotKey = GlobalKey();
  int tab = 0;

  @override
  void dispose() {
    horizontalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (horizontalController.hasClients) {
        horizontalController.jumpTo(30 * 47.0);
      }
    });
  }

  List<DateTime> get days {
    final today = DateUtils.dateOnly(DateTime.now());

    return List.generate(
      61,
      (index) => today.add(Duration(days: index - 30)),
    );
  }

  double completionForDate(
    TrackerState state,
    DateTime date,
    List<Activity> activities,
  ) {
    if (activities.isEmpty) return 0;
    final day = state.data!.completions[dates.dayKey(date)] ?? {};
    final completed = activities.where((a) => day[a.id] == true).length;
    return completed / activities.length;
  }

  int currentStreak(TrackerState state, List<Activity> activities) {
    if (activities.isEmpty) return 0;
    var count = 0;
    var date = DateTime.now();
    while (completionForDate(state, date, activities) >= 1) {
      count++;
      date = date.subtract(const Duration(days: 1));
      if (count > 3650) break;
    }
    return count;
  }

  Future<void> exportPng() async {
    final boundary = screenshotKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 2.4);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/never_give_up_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.png',
    );
    await file.writeAsBytes(byteData.buffer.asUint8List());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to ${file.path}')),
    );
  }

  Future<void> exportPdf(TrackerState state) async {
    final data = state.data!;
    final document = pw.Document();
    final active = data.activities.where((e) => e.active).toList();

    document.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text(
            'NEVER GIVE UP',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
              'Progress report — ${DateFormat('MMMM yyyy').format(DateTime.now())}'),
          pw.SizedBox(height: 20),
          pw.Text('Nickname: ${data.nickname}'),
          pw.SizedBox(height: 16),
          ...active.map((activity) {
            final done = days.where((day) {
              return data.completions[dates.dayKey(day)]?[activity.id] == true;
            }).length;
            final percent =
                active.isEmpty ? 0 : (done / days.length * 100).round();
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Text('${activity.emoji} ${activity.name}: $percent%'),
            );
          }),
          pw.SizedBox(height: 18),
          pw.Text(
            'Thought of the day: ${Motivation.forToday()}',
            style: pw.TextStyle(fontSize: 13),
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/never_give_up_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
    await file.writeAsBytes(await document.save());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved to ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackerCubit, TrackerState>(
      builder: (context, state) {
        if (state.loading || state.data == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (tab == 1)
          return ProgressPage(onBack: () => setState(() => tab = 0));
        if (tab == 2)
          return SettingsPage(onBack: () => setState(() => tab = 0));

        final activities =
            state.data!.activities.where((e) => e.active).toList();
        final todayProgress =
            completionForDate(state, DateTime.now(), activities);
        final streak = currentStreak(state, activities);

        return Scaffold(
          body: SafeArea(
            child: RepaintBoundary(
              key: screenshotKey,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: _header(
                        state.data!.nickname,
                        streak,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                      child: _progressCard(todayProgress, streak),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '30 DAY TRACKER',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.7,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('MMM yyyy').format(DateTime.now()),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: .5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _trackerGrid(state, activities),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                      child: _thoughtCard(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: (index) => setState(() => tab = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.grid_view_rounded),
                label: 'Today',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_rounded),
                label: 'Progress',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
          floatingActionButton: PopupMenuButton<String>(
            tooltip: 'Export',
            icon: const Icon(Icons.download_rounded),
            onSelected: (value) {
              if (value == 'png') exportPng();
              if (value == 'pdf') exportPdf(state);
              if (value == 'activities') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ActivityManagerPage(),
                  ),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'activities',
                child: Text('Manage activities'),
              ),
              PopupMenuItem(
                value: 'png',
                child: Text('Save tracker as PNG'),
              ),
              PopupMenuItem(
                value: 'pdf',
                child: Text('Export progress PDF'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(String nickname, int streak) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: .13),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: .3),
            ),
          ),
          child: const Icon(
            Icons.north_east_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dates.greeting(),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: .5),
                ),
              ),
              Text(
                nickname,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: .11),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.orange.withValues(alpha: .2),
            ),
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 17)),
              const SizedBox(width: 5),
              Text(
                '$streak',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _progressCard(double progress, int streak) {
    final percent = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C2415), Color(0xFF11141C)],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: .18)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 94,
            height: 94,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withValues(alpha: .07),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'today',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TODAY’S PROGRESS',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  progress >= 1
                      ? 'Perfect day. You showed up. 🔥'
                      : 'Keep going. One checkbox at a time.',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  streak > 0
                      ? '$streak day streak — protect your momentum.'
                      : 'Complete everything today to start a streak.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: .55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _trackerGrid(TrackerState state, List<Activity> activities) {
    const double nameWidth = 118.0;
    const double cellWidth = 47.0;

    if (activities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No activities yet. Use the download button → Manage activities to add your first one.',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: .65),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------------
          // FIXED ACTIVITY COLUMN
          // ------------------------------------------------------------
          SizedBox(
            width: nameWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Activity header
                SizedBox(
                  height: 66,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, top: 14),
                    child: Text(
                      'ACTIVITY',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: .48),
                      ),
                    ),
                  ),
                ),

                // Activity names + emojis
                ...activities.map(
                  (activity) => SizedBox(
                    width: nameWidth,
                    height: 58,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                        children: [
                          Text(
                            activity.emoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              activity.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ------------------------------------------------------------
          // SCROLLABLE DATE + CHECKBOX AREA
          // ------------------------------------------------------------
          Expanded(
            child: SingleChildScrollView(
              controller: horizontalController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: days.length * cellWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --------------------------------------------------
                    // DATE HEADER
                    // --------------------------------------------------
                    SizedBox(
                      height: 66,
                      child: Row(
                        children: days
                            .map(
                              (day) => SizedBox(
                                width: cellWidth,
                                height: 66,
                                child: Center(
                                  child: _dateHeader(day),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    // --------------------------------------------------
                    // CHECKBOXES
                    // --------------------------------------------------
                    ...activities.map(
                      (activity) => SizedBox(
                        height: 58,
                        child: Row(
                          children: days
                              .map(
                                (day) => SizedBox(
                                  width: cellWidth,
                                  height: 58,
                                  child: Center(
                                    child: _check(
                                      state,
                                      activity,
                                      day,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateHeader(DateTime date) {
    final today =
        DateUtils.dateOnly(DateTime.now()) == DateUtils.dateOnly(date);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          DateFormat('E').format(date)[0],
          style: TextStyle(
            fontSize: 9,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: .48),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 29,
          height: 29,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: today ? AppColors.primary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: today
                  ? Colors.black
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _check(
    TrackerState state,
    Activity activity,
    DateTime day,
  ) {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = DateUtils.dateOnly(day);
    final future = date.isAfter(today);
    final done =
        state.data!.completions[dates.dayKey(day)]?[activity.id] == true;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: future
          ? null
          : () => context.read<TrackerCubit>().toggleCompletion(
                dates.dayKey(day),
                activity.id,
              ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 31,
        height: 31,
        decoration: BoxDecoration(
          color: done
              ? AppColors.primary
              : future
                  ? Colors.transparent
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: .035),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: done
                ? AppColors.primary
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: .11),
          ),
        ),
        child: Icon(
          done
              ? Icons.check_rounded
              : future
                  ? Icons.remove_rounded
                  : null,
          size: 17,
          color: done ? Colors.black : AppColors.muted,
        ),
      ),
    );
  }

  Widget _thoughtCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.blue.withValues(alpha: .07),
        border: Border.all(color: AppColors.blue.withValues(alpha: .13)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 19,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TODAY’S THOUGHT',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w900,
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '“${Motivation.forToday()}”',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
