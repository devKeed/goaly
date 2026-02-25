import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fortune/features/pie_program/domain/entities/pie_block_category.dart';
import 'package:fortune/features/pie_program/domain/entities/pie_time_block.dart';
import 'package:fortune/features/pie_program/presentation/widgets/interactive_pie_chart.dart';

void main() {
  testWidgets('dragging a boundary emits resize callbacks', (tester) async {
    int resizeCalls = 0;

    final day = DateTime(2026, 1, 2);
    final blocks = [
      _block(day, 'sleep', 0, 720, PieBlockCategory.sleep),
      _block(day, 'work', 720, 1440, PieBlockCategory.work),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 320,
              child: InteractivePieChart(
                blocks: blocks,
                now: DateTime(2026, 1, 2, 8),
                onBoundaryResize: (index, delta) async {
                  resizeCalls++;
                  return true;
                },
                onBlockTap: (_) {},
                onBlockLongPress: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final chartCenter = tester.getCenter(find.byType(InteractivePieChart));
    final gesture = await tester.startGesture(chartCenter + const Offset(0, 150));
    await gesture.moveBy(const Offset(25, -12));
    await gesture.moveBy(const Offset(18, -10));
    await gesture.up();

    await tester.pumpAndSettle();

    expect(resizeCalls, greaterThan(0));
  });
}

PieTimeBlock _block(
  DateTime day,
  String id,
  int start,
  int end,
  PieBlockCategory category,
) {
  return PieTimeBlock(
    id: id,
    title: id,
    startTime: DateTime(day.year, day.month, day.day).add(Duration(minutes: start)),
    endTime: DateTime(day.year, day.month, day.day).add(Duration(minutes: end)),
    category: category,
    color: 0xFF000000,
    isRecurring: true,
    isLocked: false,
    createdAt: day,
  );
}
