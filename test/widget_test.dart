import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:french/main.dart';
import 'package:french/providers/progress_provider.dart';

void main() {
  testWidgets('ParlerApp renders without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const ParlerApp(),
      ),
    );

    // App should render the splash screen initially
    await tester.pump();

    // Verify the app rendered
    expect(find.byType(MaterialApp), findsOneWidget);

    // Pump past the splash screen timer (2500ms) so navigation to home fires.
    await tester.pump(const Duration(seconds: 3));

    // flutter_animate creates zero-duration timers in initState when widgets
    // mount. Each pump can trigger new widget mounts (e.g. after navigation)
    // which create more timers. Drain them by pumping several zero-duration
    // frames until all animation setup timers have resolved.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Pump enough time for all flutter_animate animations to complete
    // (longest: ~1300ms from delay + duration combinations on home screen).
    await tester.pump(const Duration(seconds: 5));

    // Final drain of any remaining zero-duration timers.
    for (var i = 0; i < 10; i++) {
      await tester.pump();
    }
  });
}
