import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/language/language_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/state/app_state.dart';
import '../../../core/models/user_role.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final success = await _authService.login(_username.text, _password.text);
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        // Default to citizen on real login
        AppStateProvider.of(context).loginAs(UserRole.citizen);
        Navigator.pushReplacementNamed(context, "/citizen/dashboard");
      }
    } else {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.loginFailed)),
        );
      }
    }
  }

  void _loginAsCitizen() {
    AppStateProvider.of(context).loginAs(UserRole.citizen);
    Navigator.pushReplacementNamed(context, "/citizen/dashboard");
  }

  void _loginAsGovernment() {
    AppStateProvider.of(context).loginAs(UserRole.government);
    Navigator.pushReplacementNamed(context, "/gov/dashboard");
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // — Language toggle —
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => lang.toggle(),
                      icon: const Icon(Icons.language, size: 20),
                      label: Text(
                        lang.isNepali ? 'EN' : 'ने',
                        style: GoogleFonts.mukta(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.deepBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: AppTheme.deepBlue,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // — Nepal-themed header —
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.crimson, AppTheme.deepBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.crimson.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🙏', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    l.namaste,
                    style: GoogleFonts.mukta(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.welcomeJanSawa,
                    style: GoogleFonts.mukta(fontSize: 16, color: AppTheme.grey),
                  ),
                  const SizedBox(height: 40),

                  // — Username —
                  TextFormField(
                    controller: _username,
                    decoration: InputDecoration(
                      labelText: l.username,
                      hintText: l.usernameHint,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? l.usernameRequired : null,
                  ),
                  const SizedBox(height: 16),

                  // — Password —
                  TextFormField(
                    controller: _password,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: l.password,
                      hintText: l.passwordHint,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l.passwordRequired;
                      if (v.length < 4) return l.passwordMin4;
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(l.forgotPassword),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // — Login button —
                  _isLoading
                      ? const SizedBox(
                          height: 52,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.crimson,
                            ),
                          ),
                        )
                      : ElevatedButton(onPressed: _login, child: Text(l.login)),
                  const SizedBox(height: 20),

                  // — Divider —
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l.or,
                          style: GoogleFonts.mukta(
                            color: AppTheme.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // — Sign up button —
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: Text(l.createAccount),
                  ),
                  const SizedBox(height: 24),

                  // — Role-based Demo Login —
                  Text(
                    "Quick Demo Access",
                    style: GoogleFonts.mukta(
                      fontSize: 14,
                      color: AppTheme.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Citizen demo
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _loginAsCitizen,
                          icon: const Icon(Icons.person, size: 18),
                          label: const Text("Citizen"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.deepBlue,
                            side: const BorderSide(color: AppTheme.deepBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Government demo
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _loginAsGovernment,
                          icon: const Icon(Icons.account_balance, size: 18),
                          label: const Text("Government"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.crimson,
                            side: const BorderSide(color: AppTheme.crimson),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // — Footer —
                  Text(
                    l.madeForNepal,
                    style: GoogleFonts.mukta(fontSize: 12, color: AppTheme.grey),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
