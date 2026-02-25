import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/controllers/pie_program_controller.dart';
import '../../application/controllers/pie_program_view_state.dart';
import '../../application/providers/pie_program_providers.dart';
import '../../domain/entities/pie_block_category.dart';
import '../../domain/entities/pie_time_block.dart';
import '../../domain/services/pie_time_utils.dart';
import '../widgets/interactive_pie_chart.dart';
import '../widgets/pie_block_editor_sheet.dart';
import '../widgets/pie_block_list.dart';
import '../widgets/pie_center_panel.dart';
import '../widgets/pie_insights_panel.dart';
import '../widgets/pie_visuals.dart';

class PieProgramScreen extends ConsumerStatefulWidget {
  const PieProgramScreen({super.key});

  @override
  ConsumerState<PieProgramScreen> createState() => _PieProgramScreenState();
}

class _PieProgramScreenState extends ConsumerState<PieProgramScreen>
    with WidgetsBindingObserver {
  TimeOfDay _sleepStart = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _sleepEnd = const TimeOfDay(hour: 7, minute: 0);
  final List<_TaskDraft> _draftTasks = [
    _TaskDraft(title: 'Work', category: PieBlockCategory.work, durationMinutes: 480),
    _TaskDraft(title: 'Gym', category: PieBlockCategory.fitness, durationMinutes: 60),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(pieProgramControllerProvider.notifier).refreshAfterAppResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(pieProgramControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Pie Program'),
        actions: [
          IconButton(
            tooltip: 'Save as template',
            onPressed: () => ref
                .read(pieProgramControllerProvider.notifier)
                .saveCurrentAsTemplate(),
            icon: const Icon(Icons.bookmark_add_outlined),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8EEF7), Color(0xFFF5F8FC)],
          ),
        ),
        child: SafeArea(
          child: asyncState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Pie Program failed to load:\n$error',
                textAlign: TextAlign.center,
              ),
            ),
            data: (data) {
              if (data.template == null) {
                return _buildOnboarding(context);
              }
              return _buildContent(context, data);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOnboarding(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set your daily template',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: PieVisuals.foreground,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'This is used every day at midnight.',
                style: TextStyle(color: PieVisuals.subForeground),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _TimeTile(
                      label: 'Sleep from',
                      value: _sleepStart,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _sleepStart,
                        );
                        if (picked != null) {
                          setState(() => _sleepStart = picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeTile(
                      label: 'Wake up',
                      value: _sleepEnd,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _sleepEnd,
                        );
                        if (picked != null) {
                          setState(() => _sleepEnd = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Recurring tasks',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: PieVisuals.foreground,
                ),
              ),
              const SizedBox(height: 8),
              ..._draftTasks.map((task) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F8FC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${task.title} · ${task.durationMinutes}m',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: PieVisuals.foreground,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _draftTasks.remove(task)),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _showTaskDraftDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add recurring task'),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final controller = ref.read(pieProgramControllerProvider.notifier);
                    await controller.createTemplateFromSetup(
                      sleepStartMinute: _sleepStart.hour * 60 + _sleepStart.minute,
                      sleepEndMinute: _sleepEnd.hour * 60 + _sleepEnd.minute,
                      recurringTasks: _draftTasks
                          .map(
                            (task) => OnboardingTaskInput(
                              title: task.title,
                              category: task.category,
                              durationMinutes: task.durationMinutes,
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                  child: const Text('Create Pie Program'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, PieProgramViewState data) {
    final rulesEngine = ref.read(pieRulesEngineProvider);
    final currentBlock = rulesEngine.currentBlock(data.schedule.blocks, data.now);
    final nextBlock = rulesEngine.nextBlock(data.schedule.blocks, data.now);

    final currentTime = DateFormat('HH:mm:ss').format(data.now);
    final countdown = currentBlock == null
        ? 'No active block'
        : '${PieTimeUtils.minutesUntil(data.now, currentBlock.endTime)}m left';

    return RefreshIndicator(
      onRefresh: () => ref.read(pieProgramControllerProvider.notifier).refreshAfterAppResume(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          const SizedBox(height: 6),
          Center(
            child: SizedBox(
              width: 340,
              height: 340,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: InteractivePieChart(
                      key: ValueKey(data.schedule.updatedAt.toIso8601String()),
                      blocks: data.schedule.blocks,
                      now: data.now,
                      onBoundaryResize: (boundaryIndex, delta) {
                        return ref.read(pieProgramControllerProvider.notifier).resizeBoundary(
                              boundaryIndex: boundaryIndex,
                              deltaMinutes: delta,
                            );
                      },
                      onBlockTap: (block) => _editBlock(context, block),
                      onBlockLongPress: (block) {
                        ref.read(pieProgramControllerProvider.notifier).toggleLock(block.id);
                      },
                    ),
                  ),
                  PieCenterPanel(
                    currentTime: currentTime,
                    currentTask: currentBlock?.title ?? 'No task',
                    countdown: countdown,
                    microText: data.motivationalText,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              nextBlock == null
                  ? 'No upcoming task before midnight.'
                  : 'Next: ${nextBlock.title} at ${DateFormat('HH:mm').format(nextBlock.startTime)}',
              style: const TextStyle(
                color: PieVisuals.subForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          PieInsightsPanel(insights: data.insights),
          const SizedBox(height: 14),
          PieBlockList(
            blocks: data.schedule.blocks,
            onTap: (block) => _editBlock(context, block),
          ),
        ],
      ),
    );
  }

  Future<void> _editBlock(BuildContext context, PieTimeBlock block) async {
    final result = await showPieBlockEditorSheet(context: context, block: block);
    if (result == null) {
      return;
    }

    final controller = ref.read(pieProgramControllerProvider.notifier);
    switch (result.action) {
      case PieBlockEditorAction.save:
        await controller.editBlock(
          blockId: block.id,
          title: result.title,
          category: result.category,
          color: result.color,
        );
      case PieBlockEditorAction.delete:
        await controller.deleteBlock(block.id);
      case PieBlockEditorAction.addAfter:
        await controller.addBlock(
          sourceBlockId: block.id,
          title: 'New Block',
          category: PieBlockCategory.other,
        );
    }
  }

  Future<void> _showTaskDraftDialog(BuildContext context) async {
    final titleController = TextEditingController();
    PieBlockCategory selectedCategory = PieBlockCategory.work;
    final durationController = TextEditingController(text: '60');

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Recurring task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<PieBlockCategory>(
                value: selectedCategory,
                items: PieBlockCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedCategory = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  return;
                }
                final duration = int.tryParse(durationController.text) ?? 60;
                setState(() {
                  _draftTasks.add(
                    _TaskDraft(
                      title: title,
                      category: selectedCategory,
                      durationMinutes: duration,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskDraft {
  const _TaskDraft({
    required this.title,
    required this.category,
    required this.durationMinutes,
  });

  final String title;
  final PieBlockCategory category;
  final int durationMinutes;
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final TimeOfDay value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FC),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: PieVisuals.subForeground,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.format(context),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: PieVisuals.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
