import 'package:flutter_test/flutter_test.dart';

import 'package:fortune/features/pie_program/domain/entities/pie_block_category.dart';
import 'package:fortune/features/pie_program/domain/entities/pie_time_block.dart';
import 'package:fortune/features/pie_program/domain/services/pie_rules_engine.dart';

void main() {
  group('PieRulesEngine', () {
    late PieRulesEngine engine;
    late DateTime day;

    setUp(() {
      engine = PieRulesEngine();
      day = DateTime(2026, 1, 2);
    });

    test('validateFullDay accepts contiguous 24h schedule', () {
      final blocks = [
        _block(day, 'sleep', 0, 480, PieBlockCategory.sleep),
        _block(day, 'work', 480, 960, PieBlockCategory.work),
        _block(day, 'personal', 960, 1440, PieBlockCategory.personal),
      ];

      final result = engine.validateFullDay(blocks);
      expect(result.isValid, isTrue);
    });

    test('resizeBoundary enforces min duration and reports resistance', () {
      final blocks = [
        _block(day, 'a', 0, 30, PieBlockCategory.sleep),
        _block(day, 'b', 30, 1440, PieBlockCategory.work),
      ];

      final result = engine.resizeBoundary(
        source: blocks,
        boundaryIndex: 0,
        deltaMinutes: -30,
      );

      expect(result.appliedDelta, -15);
      expect(result.hitLimit, isTrue);
      expect(result.blocks.first.durationMinutes, 15);
    });

    test('deleteBlock merges into neighbor while keeping 24h', () {
      final blocks = [
        _block(day, 'sleep', 0, 480, PieBlockCategory.sleep, locked: true),
        _block(day, 'work', 480, 900, PieBlockCategory.work),
        _block(day, 'gym', 900, 960, PieBlockCategory.fitness),
        _block(day, 'free', 960, 1440, PieBlockCategory.personal),
      ];

      final result = engine.deleteBlock(source: blocks, blockId: 'gym');

      expect(result.success, isTrue);
      expect(result.blocks.length, 3);
      final total = result.blocks.fold<int>(0, (s, b) => s + b.durationMinutes);
      expect(total, 1440);
    });
  });
}

PieTimeBlock _block(
  DateTime day,
  String id,
  int start,
  int end,
  PieBlockCategory category, {
  bool locked = false,
}) {
  return PieTimeBlock(
    id: id,
    title: id,
    startTime: DateTime(day.year, day.month, day.day).add(Duration(minutes: start)),
    endTime: DateTime(day.year, day.month, day.day).add(Duration(minutes: end)),
    category: category,
    color: 0xFF000000,
    isRecurring: true,
    isLocked: locked,
    createdAt: day,
  );
}
