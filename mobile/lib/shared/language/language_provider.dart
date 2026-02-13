import 'package:flutter/material.dart';

/// Manages the current locale and rebuilds the app when toggled.
class LanguageProvider extends StatefulWidget {
  final Widget Function(Locale locale) builder;

  const LanguageProvider({super.key, required this.builder});

  @override
  State<LanguageProvider> createState() => LanguageProviderState();

  /// Access from anywhere below this widget.
  static LanguageProviderState of(BuildContext context) {
    final state = context.findAncestorStateOfType<LanguageProviderState>();
    if (state == null) {
      throw FlutterError(
        'LanguageProvider.of() called with a context that does not contain a LanguageProvider.\n'
        'No LanguageProvider ancestor could be found starting from the context that was passed to LanguageProvider.of().',
      );
    }
    return state;
  }
}

class LanguageProviderState extends State<LanguageProvider> {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isNepali => _locale.languageCode == 'ne';

  void toggle() {
    setState(() {
      _locale = _locale.languageCode == 'ne'
          ? const Locale('en')
          : const Locale('ne');
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(_locale);
}
