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
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _otpSent = false;

  void _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authService.sendOTP(_phoneController.text.trim());
      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP sent successfully (Dev: 123456)")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String message = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $message"),
            backgroundColor: AppTheme.crimson,
          ),
        );
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length < 4) return;

    setState(() => _isLoading = true);

    try {
      // For existing users: only send phone + otp (no name/role/municipality)
      final user = await _authService.verifyOTP(
        phone: _phoneController.text.trim(),
        otp: _otpController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
        final appState = AppStateProvider.of(context);
        await appState.setRealUser(user);

        // Route based on backend-returned role (not the selector)
        String nextRoute = '/citizen/dashboard';
        if (user.role == UserRole.government) {
          nextRoute = '/gov/dashboard';
        }
        // Providers share citizen nav (route guards allow both)

        Navigator.pushReplacementNamed(context, nextRoute);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Verification failed. Please try again."),
            backgroundColor: AppTheme.crimson,
          ),
        );
      }
    } on NewUserException {
      // Phone not registered — redirect to signup with phone pre-filled
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Phone not registered. Please create an account."),
          backgroundColor: AppTheme.deepBlue,
        ),
      );
      Navigator.pushNamed(
        context,
        '/signup',
        arguments: {'phone': _phoneController.text.trim()},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppTheme.crimson),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    final l = AppLocalizations.of(context);
    
    // Safety check: if localizations are missing, show a simple error instead of crashing
    if (l == null) {
      return const Scaffold(
        body: Center(child: Text('Localizations not initialized.')),
      );
    }

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
                  // Language toggle
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => lang.toggle(),
                      icon: const Icon(Icons.language, size: 20),
                      label: Text(lang.isNepali ? 'EN' : 'ने'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nepal-themed header
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppTheme.crimson, AppTheme.deepBlue],
                      ),
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l.welcomeJanSawa,
                    style: GoogleFonts.mukta(
                      fontSize: 16,
                      color: AppTheme.grey,
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (!_otpSent) ...[
                    // Step 1: Phone Number
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        hintText: "98XXXXXXXX",
                        prefixIcon: Icon(Icons.phone_android),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Enter phone number";
                        if (!v.startsWith('98')) return "Must start with 98";
                        if (v.length != 10) return "Must be 10 digits";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _sendOTP,
                              child: const Text("Send OTP"),
                            ),
                          ),
                  ] else ...[
                    // Step 2: OTP
                    Text(
                      "Enter 6-digit OTP sent to ${_phoneController.text}",
                      style: GoogleFonts.mukta(color: AppTheme.grey),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: "OTP Code",
                        prefixIcon: Icon(Icons.lock_clock_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _verifyOTP,
                              child: const Text("Verify & Login"),
                            ),
                          ),
                    TextButton(
                      onPressed: () => setState(() => _otpSent = false),
                      child: const Text("Change Phone Number"),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Create Account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.mukta(color: AppTheme.grey),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/signup'),
                        child: Text(
                          l.createAccount,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Text(
                    l.madeForNepal,
                    style: GoogleFonts.mukta(
                      fontSize: 12,
                      color: AppTheme.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
