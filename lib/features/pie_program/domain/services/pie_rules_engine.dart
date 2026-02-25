import '../entities/pie_block_category.dart';
import '../entities/pie_day_schedule.dart';
import '../entities/pie_template.dart';
import '../entities/pie_template_block.dart';
import '../entities/pie_time_block.dart';
import 'pie_time_utils.dart';

class PieValidationResult {
  const PieValidationResult({required this.isValid, required this.message});

  final bool isValid;
  final String message;
}

class PieResizeResult {
  const PieResizeResult({
    required this.blocks,
    required this.appliedDelta,
    required this.hitLimit,
  });

  final List<PieTimeBlock> blocks;
  final int appliedDelta;
  final bool hitLimit;
}

class PieOperationResult {
  const PieOperationResult({
    required this.blocks,
    required this.success,
    this.errorMessage,
  });

  final List<PieTimeBlock> blocks;
  final bool success;
  final String? errorMessage;
}

class PieRulesEngine {
  static const int minutesInDay = PieTimeUtils.minutesInDay;
  static const int minBlockDurationMinutes = 15;

  PieValidationResult validateFullDay(List<PieTimeBlock> source) {
    if (source.isEmpty) {
      return const PieValidationResult(
        isValid: false,
        message: 'At least one block is required.',
      );
    }

    final blocks = sorted(source);
    if (blocks.first.startMinuteOfDay != 0) {
      return const PieValidationResult(
        isValid: false,
        message: 'Schedule must start at 00:00.',
      );
    }

    if (blocks.last.endMinuteOfDay != minutesInDay) {
      return const PieValidationResult(
        isValid: false,
        message: 'Schedule must end at 24:00.',
      );
    }

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      if (block.durationMinutes <= 0) {
        return PieValidationResult(
          isValid: false,
          message: 'Block "${block.title}" has invalid duration.',
        );
      }

      if (i > 0) {
        final previous = blocks[i - 1];
        if (previous.endMinuteOfDay != block.startMinuteOfDay) {
          return const PieValidationResult(
            isValid: false,
            message: 'Blocks cannot overlap or leave gaps.',
          );
        }
      }
    }

    final totalMinutes = blocks.fold<int>(
      0,
      (sum, block) => sum + block.durationMinutes,
    );

    if (totalMinutes != minutesInDay) {
      return const PieValidationResult(
        isValid: false,
        message: 'Total allocated time must equal 24 hours.',
      );
    }

    return const PieValidationResult(isValid: true, message: 'ok');
  }

  List<PieTimeBlock> sorted(List<PieTimeBlock> source) {
    final copy = [...source];
    copy.sort((a, b) => a.startTime.compareTo(b.startTime));
    return copy;
  }

  PieResizeResult resizeBoundary({
    required List<PieTimeBlock> source,
    required int boundaryIndex,
    required int deltaMinutes,
  }) {
    if (source.length < 2 || boundaryIndex < 0 || boundaryIndex >= source.length - 1) {
      return PieResizeResult(
        blocks: source,
        appliedDelta: 0,
        hitLimit: true,
      );
    }

    final blocks = sorted(source);
    final left = blocks[boundaryIndex];
    final right = blocks[boundaryIndex + 1];

    if (left.isLocked || right.isLocked) {
      return PieResizeResult(
        blocks: blocks,
        appliedDelta: 0,
        hitLimit: true,
      );
    }

    final maxPositive = right.durationMinutes - minBlockDurationMinutes;
    final maxNegative = -(left.durationMinutes - minBlockDurationMinutes);

    final clampedDelta = deltaMinutes.clamp(maxNegative, maxPositive);
    final appliedDelta = clampedDelta;

    if (appliedDelta == 0) {
      return PieResizeResult(
        blocks: blocks,
        appliedDelta: 0,
        hitLimit: deltaMinutes != 0,
      );
    }

    final day = PieTimeUtils.dateOnly(left.startTime);
    final newBoundary = left.endMinuteOfDay + appliedDelta;

    final updatedLeft = left.copyWith(
      endTime: PieTimeUtils.fromMinutes(day, newBoundary),
    );
    final updatedRight = right.copyWith(
      startTime: PieTimeUtils.fromMinutes(day, newBoundary),
    );

    final updated = [...blocks];
    updated[boundaryIndex] = updatedLeft;
    updated[boundaryIndex + 1] = updatedRight;

    return PieResizeResult(
      blocks: updated,
      appliedDelta: appliedDelta,
      hitLimit: appliedDelta != deltaMinutes,
    );
  }

  PieOperationResult addBlock({
    required List<PieTimeBlock> source,
    required String sourceBlockId,
    required PieTimeBlock newBlock,
  }) {
    final blocks = sorted(source);
    final index = blocks.indexWhere((block) => block.id == sourceBlockId);
    if (index < 0) {
      return PieOperationResult(
        blocks: blocks,
        success: false,
        errorMessage: 'Source block not found.',
      );
    }

    final sourceBlock = blocks[index];
    if (sourceBlock.isLocked) {
      return PieOperationResult(
        blocks: blocks,
        success: false,
        errorMessage: 'Locked blocks cannot be split.',
      );
    }

    if (sourceBlock.durationMinutes < minBlockDurationMinutes * 2) {
      return PieOperationResult(
        blocks: blocks,
        success: false,
        errorMessage: 'Source block is too small to split.',
      );
    }

    final insertedDuration = newBlock.durationMinutes.clamp(
      minBlockDurationMinutes,
      sourceBlock.durationMinutes - minBlockDurationMinutes,
    );
    final splitMinute = sourceBlock.endMinuteOfDay - insertedDuration;
    final day = PieTimeUtils.dateOnly(sourceBlock.startTime);

    final updatedSource = sourceBlock.copyWith(
      endTime: PieTimeUtils.fromMinutes(day, splitMinute),
    );

    final inserted = newBlock.copyWith(
      startTime: PieTimeUtils.fromMinutes(day, splitMinute),
      endTime: PieTimeUtils.fromMinutes(day, sourceBlock.endMinuteOfDay),
    );

    final updated = [...blocks];
    updated[index] = updatedSource;
    updated.insert(index + 1, inserted);

    final validation = validateFullDay(updated);
    if (!validation.isValid) {
      return PieOperationResult(
        blocks: blocks,
        success: false,
        errorMessage: validation.message,
      );
    }

    return PieOperationResult(blocks: updated, success: true);
  }

  PieOperationResult deleteBlock({
    required List<PieTimeBlock> source,
    required String blockId,
  }) {
    final blocks = sorted(source);
    if (blocks.length == 1) {
      return PieOperationResult(
        blocks: blocks,
        success: false,
        errorMessage: 'At least one block must remain.',
      );
    }

    final index = blocks.indexWhere((block) => block.id == blockId);
    if (index < 0) {
      return PieOperationResult(
        blocks: blocks,
        success: false,
        errorMessage: 'Block not found.',
      );
    }

    final selected = blocks[index];
    if (selected.isLocked) {
      return PieOperationResult(
        blocks: blocks,
        success: false,
        errorMessage: 'Locked blocks cannot be deleted.',
      );
    }

    final day = PieTimeUtils.dateOnly(selected.startTime);
    final updated = [...blocks]..removeAt(index);

    if (index > 0 && !updated[index - 1].isLocked) {
      final previous = updated[index - 1];
      updated[index - 1] = previous.copyWith(
        endTime: PieTimeUtils.fromMinutes(day, selected.endMinuteOfDay),
      );
    } else if (index < updated.length && !updated[index].isLocked) {
      final next = updated[index];
      updated[index] = next.copyWith(
        startTime: PieTimeUtils.fromMinutes(day, selected.startMinuteOfDay),
      );
    } else {
      return PieOperationResult(
        blocks: blocks,
        success: false,
        errorMessage: 'Neighbor blocks are locked.',
      );
    }

    final validation = validateFullDay(updated);
    if (!validation.isValid) {
      return PieOperationResult(
        blocks: blocks,
        success: false,
        errorMessage: validation.message,
      );
    }

    return PieOperationResult(blocks: updated, success: true);
  }

  List<PieTemplateBlock> toTemplateBlocks(List<PieTimeBlock> blocks) {
    final sortedBlocks = sorted(blocks);
    return sortedBlocks
        .map(
          (block) => PieTemplateBlock(
            id: block.id,
            title: block.title,
            startMinute: block.startMinuteOfDay,
            endMinute: block.endMinuteOfDay,
            category: block.category,
            color: block.color,
            isRecurring: block.isRecurring,
            isLocked: block.isLocked,
            createdAt: block.createdAt,
          ),
        )
        .toList(growable: false);
  }

  List<PieTimeBlock> fromTemplateBlocks({
    required DateTime date,
    required List<PieTemplateBlock> templateBlocks,
  }) {
    final day = PieTimeUtils.dateOnly(date);
    final converted = templateBlocks
        .map(
          (block) => PieTimeBlock(
            id: block.id,
            title: block.title,
            startTime: PieTimeUtils.fromMinutes(day, block.startMinute),
            endTime: PieTimeUtils.fromMinutes(day, block.endMinute),
            category: block.category,
            color: block.color,
            isRecurring: block.isRecurring,
            isLocked: block.isLocked,
            createdAt: block.createdAt,
          ),
        )
        .toList(growable: false);

    return sorted(converted);
  }

  PieDaySchedule scheduleFromTemplate({
    required DateTime date,
    required PieTemplate template,
  }) {
    final now = DateTime.now();
    return PieDaySchedule(
      date: PieTimeUtils.dateOnly(date),
      blocks: fromTemplateBlocks(date: date, templateBlocks: template.blocks),
      createdAt: now,
      updatedAt: now,
      isArchived: false,
    );
  }

  PieTimeBlock? currentBlock(List<PieTimeBlock> blocks, DateTime now) {
    final minute = PieTimeUtils.toMinutes(now);
    for (final block in sorted(blocks)) {
      if (minute >= block.startMinuteOfDay && minute < block.endMinuteOfDay) {
        return block;
      }
    }
    return null;
  }

  PieTimeBlock? nextBlock(List<PieTimeBlock> blocks, DateTime now) {
    final minute = PieTimeUtils.toMinutes(now);
    for (final block in sorted(blocks)) {
      if (block.startMinuteOfDay > minute) {
        return block;
      }
    }
    return null;
  }

  PieTemplate buildDefaultTemplate({
    required DateTime createdAt,
    required int sleepStartMinute,
    required int sleepDurationMinutes,
  }) {
    final sleepEnd = (sleepStartMinute + sleepDurationMinutes).clamp(0, minutesInDay);
    final wakeStart = sleepEnd;
    final workEnd = (wakeStart + 8 * 60).clamp(wakeStart, minutesInDay);
    final focusEnd = (workEnd + 2 * 60).clamp(workEnd, minutesInDay);

    final blocks = <PieTemplateBlock>[
      PieTemplateBlock(
        id: 'sleep',
        title: 'Sleep',
        startMinute: 0,
        endMinute: wakeStart,
        category: PieBlockCategory.sleep,
        color: 0xFF5C6BC0,
        isRecurring: true,
        isLocked: true,
        createdAt: createdAt,
      ),
      PieTemplateBlock(
        id: 'work',
        title: 'Work',
        startMinute: wakeStart,
        endMinute: workEnd,
        category: PieBlockCategory.work,
        color: 0xFF26A69A,
        isRecurring: true,
        isLocked: false,
        createdAt: createdAt,
      ),
      PieTemplateBlock(
        id: 'focus',
        title: 'Focus',
        startMinute: workEnd,
        endMinute: focusEnd,
        category: PieBlockCategory.focus,
        color: 0xFF42A5F5,
        isRecurring: true,
        isLocked: false,
        createdAt: createdAt,
      ),
      PieTemplateBlock(
        id: 'personal',
        title: 'Personal',
        startMinute: focusEnd,
        endMinute: minutesInDay,
        category: PieBlockCategory.personal,
        color: 0xFFFFA726,
        isRecurring: true,
        isLocked: false,
        createdAt: createdAt,
      ),
    ];

    return PieTemplate(
      id: 'default_template',
      blocks: blocks,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }
}
