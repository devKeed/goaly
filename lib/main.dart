import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'features/pie_program/infrastructure/services/pie_background_scheduler.dart';
import 'features/pie_program/presentation/screens/pie_program_screen.dart';
import 'features/steps/presentation/screens/steps_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/home_screen.dart';
import 'screens/tasks_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();
  await storageService.checkAndPerformResets();
  await HomeWidget.setAppGroupId('group.com.fortune.cooking.fortune.pie');
  final backgroundScheduler = PieBackgroundScheduler();
  await backgroundScheduler.initialize();
  await backgroundScheduler.schedulePeriodicWidgetRefresh();

  runApp(ProviderScope(child: FortuneApp(storageService: storageService)));
}

class FortuneApp extends StatefulWidget {
  const FortuneApp({super.key, required this.storageService});

  final StorageService storageService;

  @override
  State<FortuneApp> createState() => _FortuneAppState();
}

class _FortuneAppState extends State<FortuneApp> {
  StreamSubscription<Uri?>? _widgetClickSubscription;
  int _pieLaunchIndex = -1;

  @override
  void initState() {
    super.initState();
    _widgetClickSubscription = HomeWidget.widgetClicked.listen(
      _handleWidgetUri,
    );
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_handleWidgetUri);
  }

  @override
  void dispose() {
    _widgetClickSubscription?.cancel();
    super.dispose();
  }

  void _handleWidgetUri(Uri? uri) {
    if (uri == null) return;
    if (uri.path.contains('pie-program')) {
      setState(() => _pieLaunchIndex = 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fortune',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.standard,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          error: AppColors.error,
          surface: AppColors.surface,
          onPrimary: AppColors.background,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        canvasColor: AppColors.background,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.subtleDivider),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.background.withValues(alpha: 0.96),
          elevation: 0,
          height: 68,
          indicatorColor: AppColors.navIndicator,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 23);
            }
            return const IconThemeData(
              color: AppColors.navUnselected,
              size: 23,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              );
            }
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.navUnselected,
            );
          }),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shape: CircleBorder(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceElevated,
          hintStyle: const TextStyle(color: AppColors.textTertiary),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.subtleDivider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: AppColors.surfaceElevated,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return AppColors.surfaceVariant;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.textPrimary;
              }
              return AppColors.textSecondary;
            }),
            side: const WidgetStatePropertyAll(
              BorderSide(color: AppColors.subtleDivider),
            ),
          ),
        ),
      ),
      home: FortuneShell(
        storageService: widget.storageService,
        initialIndex: _pieLaunchIndex >= 0 ? _pieLaunchIndex : 0,
      ),
    );
  }
}

class FortuneShell extends StatefulWidget {
  final StorageService storageService;
  final int initialIndex;

  const FortuneShell({
    super.key,
    required this.storageService,
    this.initialIndex = 0,
  });

  @override
  State<FortuneShell> createState() => _FortuneShellState();
}

class _FortuneShellState extends State<FortuneShell> {
  late int _currentIndex;
  late bool _stepsVisited;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _stepsVisited = widget.initialIndex == 4;
  }

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 4) {
        _stepsVisited = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            storageService: widget.storageService,
            onNavigateToGoals: () => _switchTab(1),
            onNavigateToPie: () => _switchTab(2),
            onNavigateToTasks: () => _switchTab(3),
            onNavigateToSteps: () => _switchTab(4),
          ),
          GoalsScreen(storageService: widget.storageService),
          const PieProgramScreen(),
          TasksScreen(storageService: widget.storageService),
          _stepsVisited ? const StepsScreen() : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _switchTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(CupertinoIcons.house),
            selectedIcon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.flag),
            selectedIcon: Icon(CupertinoIcons.flag_fill),
            label: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.chart_pie),
            selectedIcon: Icon(CupertinoIcons.chart_pie_fill),
            label: 'Pie',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.checkmark_circle),
            selectedIcon: Icon(CupertinoIcons.checkmark_circle_fill),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_walk_outlined),
            selectedIcon: Icon(Icons.directions_walk_rounded),
            label: 'Steps',
          ),
        ],
      ),
    );
  }
}
