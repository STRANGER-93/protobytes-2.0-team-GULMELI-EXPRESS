import 'package:flutter/material.dart';
import 'core/routes.dart';
import 'core/state/app_state.dart';
import 'core/models/user_role.dart';
import 'shared/theme/app_theme.dart';
import 'shared/language/language_provider.dart';
import 'l10n/generated/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      notifier: _appState,
      child: LanguageProvider(
        builder: (locale) => Builder(
          builder: (ctx) {
            final appState = AppStateProvider.of(ctx);

            // Show splash while checking stored session
            if (appState.isLoading) {
              return MaterialApp(
                key: const ValueKey('splash'),
                debugShowCheckedModeBanner: false,
                theme: AppTheme.nepaliTheme,
                home: const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            // Determine initial route based on stored session
            String initialRoute = '/';
            if (appState.isAuthenticated) {
              final user = appState.currentUser;
              if (user != null) {
                if (user.role == UserRole.government) {
                  initialRoute = '/gov/dashboard';
                } else {
                  initialRoute = '/citizen/dashboard';
                }
              }
            }

            return MaterialApp(
              key: const ValueKey('app'),
              title: 'JanSewa',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.nepaliTheme,
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              initialRoute: initialRoute,
              onGenerateRoute: (settings) =>
                  AppRoutes.generateRoute(settings, ctx),
            );
          },
        ),
      ),
    );
  }
}
