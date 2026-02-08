import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/lessons/lessons_screen.dart';
import '../../screens/lessons/lesson_detail_screen.dart';
import '../../screens/words/words_screen.dart';
import '../../screens/words/flashcard_screen.dart';
import '../../screens/words/vocab_quiz_screen.dart';
import '../../screens/tef/tef_screen.dart';
import '../../screens/tef/tef_play_screen.dart';
import '../../screens/quiz/quiz_screen.dart';
import '../../screens/quiz/quiz_play_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../constants/app_colors.dart';

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
          path: '/lessons',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LessonsScreen()),
        ),
        GoRoute(
          path: '/words',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: WordsScreen()),
        ),
        GoRoute(
          path: '/tef',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: TefScreen()),
        ),
        GoRoute(
          path: '/quiz',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: QuizScreen()),
        ),
      ],
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
        // Support passing wordIds via extra for session-based quizzes.
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

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/words')) return 1;
    if (location.startsWith('/tef')) return 2;
    if (location.startsWith('/quiz')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              children: [
                _NavItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Lessons',
                  isActive: index == 0,
                  onTap: () => context.go('/lessons'),
                ),
                _NavItem(
                  icon: Icons.translate_rounded,
                  label: 'Words',
                  isActive: index == 1,
                  onTap: () => context.go('/words'),
                ),
                _NavItem(
                  icon: Icons.school_rounded,
                  label: 'TEF',
                  isActive: index == 2,
                  onTap: () => context.go('/tef'),
                ),
                _NavItem(
                  icon: Icons.quiz_rounded,
                  label: 'Quiz',
                  isActive: index == 3,
                  onTap: () => context.go('/quiz'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
