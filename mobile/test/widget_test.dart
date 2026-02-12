import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jansawa/l10n/generated/app_localizations.dart';
import 'package:jansawa/features/auth/screens/login_screen.dart';
import 'package:jansawa/shared/theme/app_theme.dart';
import 'package:jansawa/shared/language/language_provider.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build the login screen wrapped with l10n delegates and language provider.
    await tester.pumpWidget(
      LanguageProvider(
        builder: (locale) => MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.nepaliTheme,
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Nepali login labels are rendered.
    expect(find.text('नमस्ते!'), findsOneWidget);
    expect(find.text('प्रयोगकर्ता नाम'), findsOneWidget);
    expect(find.text('पासवर्ड'), findsOneWidget);
    expect(find.text('लगइन गर्नुहोस्'), findsOneWidget);
    expect(find.text('नयाँ खाता बनाउनुहोस्'), findsOneWidget);
  });
}
