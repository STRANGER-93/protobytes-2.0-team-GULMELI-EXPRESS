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
  UserRole _selectedRole = UserRole.citizen;

  String _getBackendRole(UserRole role) {
    return role == UserRole.government ? 'municipality_admin' : 'citizen';
  }

  void _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authService.sendOTP(
        _phoneController.text.trim(),
      );
      setState(() {
        _isLoading = false;
        _otpSent = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP sent successfully (Dev: 123456)")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
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
    final user = await _authService.verifyOTP(
      phone: _phoneController.text.trim(),
      otp: _otpController.text.trim(),
      // Backend requires name/municipality for new users.
      // Since we removed name field, we set a default here.
      name: "JanSewa User", 
      role: _getBackendRole(_selectedRole),
      municipality: 1, // Matches our seeded municipality
    );
    setState(() => _isLoading = false);

    if (user != null && mounted) {
      final appState = AppStateProvider.of(context);
      appState.setRealUser(user);

      String nextRoute = '/citizen';
      if (user.role == UserRole.government) {
        nextRoute = '/government';
      }

      Navigator.pushReplacementNamed(context, nextRoute);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid OTP or Verification Failed"),
            backgroundColor: AppTheme.crimson,
          ),
        );
      }
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
                    child: const Center(child: Text('🙏', style: TextStyle(fontSize: 40))),
                  ),
                  const SizedBox(height: 20),
                  Text(l.namaste, style: GoogleFonts.mukta(fontSize: 32, fontWeight: FontWeight.bold)),
                  Text(l.welcomeJanSawa, style: GoogleFonts.mukta(fontSize: 16, color: AppTheme.grey)),
                  const SizedBox(height: 40),

                  // Role Selection
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("Citizen"),
                          selected: _selectedRole == UserRole.citizen,
                          onSelected: (val) => setState(() => _selectedRole = UserRole.citizen),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("Government"),
                          selected: _selectedRole == UserRole.government,
                          onSelected: (val) => setState(() => _selectedRole = UserRole.government),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (!_otpSent) ...[
                    // Step 1: Phone Number
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        hintText: "98XXXXXXXX",
                        prefixIcon: const Icon(Icons.phone_android),
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
                      : ElevatedButton(onPressed: _sendOTP, child: const Text("Send OTP")),
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
                      : ElevatedButton(onPressed: _verifyOTP, child: const Text("Verify & Login")),
                    TextButton(
                      onPressed: () => setState(() => _otpSent = false),
                      child: const Text("Change Phone Number"),
                    ),
                  ],

                  const SizedBox(height: 40),
                  Text(l.madeForNepal, style: GoogleFonts.mukta(fontSize: 12, color: AppTheme.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

