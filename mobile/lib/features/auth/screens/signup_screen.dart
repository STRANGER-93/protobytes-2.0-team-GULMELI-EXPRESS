import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/language/language_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final success = await _authService.register(
      fullName: _fullName.text.trim(),
      email: _email.text.trim(),
      username: _username.text.trim(),
      password: _password.text,
    );
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.registerSuccess)));
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.registerFailed)));
      }
    }
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _username.dispose();
    _password.dispose();
    _confirmPassword.dispose();
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

                  // — Language toggle (top-right) —
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
                  const SizedBox(height: 12),

                  // — Header —
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.deepBlue, AppTheme.crimson],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.deepBlue.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_add_outlined,
                        color: AppTheme.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    l.createAccountTitle,
                    style: GoogleFonts.mukta(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.joinJanSawa,
                    style: GoogleFonts.mukta(
                      fontSize: 15,
                      color: AppTheme.grey,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // — Full name —
                  TextFormField(
                    controller: _fullName,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: l.fullName,
                      hintText: l.fullNameHint,
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l.fullNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // — Email —
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l.email,
                      hintText: 'example@mail.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l.emailRequired;
                      }
                      if (!RegExp(
                        r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value.trim())) {
                        return l.emailInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // — Username —
                  TextFormField(
                    controller: _username,
                    decoration: InputDecoration(
                      labelText: l.username,
                      hintText: l.usernameChoose,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l.usernameRequired;
                      }
                      if (value.trim().length < 3) {
                        return l.usernameMin3;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // — Password —
                  TextFormField(
                    controller: _password,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: l.password,
                      hintText: l.passwordMin6Hint,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l.passwordRequired;
                      }
                      if (value.length < 6) {
                        return l.passwordMin6;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // — Confirm password —
                  TextFormField(
                    controller: _confirmPassword,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: l.confirmPassword,
                      hintText: l.confirmPasswordHint,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l.confirmPasswordRequired;
                      }
                      if (value != _password.text) {
                        return l.passwordMismatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // — Sign up button —
                  _isLoading
                      ? const SizedBox(
                          height: 52,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.crimson,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _signup,
                          child: Text(l.register),
                        ),
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

                  // — Back to login —
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l.alreadyHaveAccount),
                  ),
                  const SizedBox(height: 24),

                  // — Footer —
                  Text(
                    l.madeForNepal,
                    style: GoogleFonts.mukta(
                      fontSize: 12,
                      color: AppTheme.grey,
                    ),
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
