import 'package:flutter/material.dart';
import 'core/routes.dart';
import 'core/state/app_state.dart';
import 'shared/theme/app_theme.dart';
import 'shared/language/language_provider.dart';
import 'l10n/generated/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      builder: (_) => LanguageProvider(
        builder: (locale) => Builder(
          builder: (ctx) => MaterialApp(
            title: 'JanSawa',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.nepaliTheme,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: "/",
            onGenerateRoute: (settings) =>
                AppRoutes.generateRoute(settings, ctx),
          ),
        ),
      ),
    );
  }
}
