import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/today/today_screen.dart';
import '../../screens/learn/learn_screen.dart';
import '../../screens/profile/new_profile_screen.dart';
import '../../screens/session/session_screen.dart';
import '../../screens/session/session_complete_screen.dart';
import '../../screens/lessons/lesson_detail_screen.dart';
import '../../screens/words/flashcard_screen.dart';
import '../../screens/words/vocab_quiz_screen.dart';
import '../../screens/tef/tef_screen.dart';
import '../../screens/tef/tef_play_screen.dart';
import '../../screens/quiz/quiz_play_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../constants/app_colors.dart';
import '../constants/responsive.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/today',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: TodayScreen()),
        ),
        GoRoute(
          path: '/learn',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LearnScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: NewProfileScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/session',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          child: const SessionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/session/complete',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return CustomTransitionPage(
          child: SessionCompleteScreen(
            reviewedCount: extra['reviewed'] as int? ?? 0,
            newWordsCount: extra['newWords'] as int? ?? 0,
            correctCount: extra['correct'] as int? ?? 0,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    GoRoute(
      path: '/lesson/:id',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 1;
        return CustomTransitionPage(
          child: LessonDetailScreen(chapterId: id),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/tef',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          child: const TefScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/tef/:testId',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final testId = state.pathParameters['testId'] ?? '';
        return CustomTransitionPage(
          child: TefPlayScreen(testId: testId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/words/quiz/:category',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final category = state.pathParameters['category'] ?? '';
        final extra = state.extra;
        final List<String>? wordIds =
            extra is List ? extra.cast<String>() : null;
        return CustomTransitionPage(
          child: wordIds != null
              ? VocabQuizScreen(wordIds: wordIds)
              : VocabQuizScreen(category: category),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/words/:category',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final category = state.pathParameters['category'] ?? '';
        return CustomTransitionPage(
          child: FlashcardScreen(category: category),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/quiz/:chapterId',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final id = int.tryParse(state.pathParameters['chapterId'] ?? '') ?? 1;
        return CustomTransitionPage(
          child: QuizPlayScreen(chapterId: id),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );
      },
    ),
  ],
);

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _destinations = [
    _NavDest(icon: Icons.today_rounded, label: 'Today', path: '/today'),
    _NavDest(icon: Icons.menu_book_rounded, label: 'Learn', path: '/learn'),
    _NavDest(icon: Icons.person_rounded, label: 'Profile', path: '/profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/learn')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final useRail = context.isExpanded;

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: (i) =>
                  context.go(_destinations[i].path),
              labelType: NavigationRailLabelType.all,
              backgroundColor:
                  isDark ? AppColors.darkSurface : AppColors.white,
              indicatorColor: AppColors.red.withValues(alpha: 0.12),
              selectedIconTheme: const IconThemeData(color: AppColors.red),
              unselectedIconTheme: IconThemeData(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.navInactive,
              ),
              selectedLabelTextStyle: TextStyle(
                color: AppColors.red,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.navInactive,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              destinations: _destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            VerticalDivider(
              thickness: 1,
              width: 1,
              color: isDark ? AppColors.darkDivider : AppColors.surfaceDark,
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : AppColors.navy.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: _destinations
                  .asMap()
                  .entries
                  .map((e) => _NavItem(
                        icon: e.value.icon,
                        label: e.value.label,
                        isActive: index == e.key,
                        onTap: () => context.go(e.value.path),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavDest {
  final IconData icon;
  final String label;
  final String path;
  const _NavDest({required this.icon, required this.label, required this.path});
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.navInactive;
    return Expanded(
      child: Semantics(
        button: true,
        selected: isActive,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.red.withValues(alpha: isDark ? 0.2 : 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isActive ? AppColors.red : inactiveColor,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? AppColors.red : inactiveColor,
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
