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
    assert(state != null, 'LanguageProvider not found in widget tree');
    return state!;
  }
}

class LanguageProviderState extends State<LanguageProvider> {
  Locale _locale = const Locale('ne');

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
