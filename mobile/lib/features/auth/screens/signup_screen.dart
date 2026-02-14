import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/language/language_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/state/app_state.dart';
import '../../../core/models/user_role.dart';
import '../services/auth_service.dart';

/// OTP-based signup screen for new users.
/// Backend requires: phone, otp, name, role, municipality for registration.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _otpSent = false;
  UserRole _selectedRole = UserRole.citizen;
  int? _selectedMunicipalityId;
  List<Map<String, dynamic>> _municipalities = [];
  bool _loadingMunicipalities = true;

  @override
  void initState() {
    super.initState();
    _loadMunicipalities();

    // Pre-fill phone if passed as route argument
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['phone'] != null) {
        _phoneController.text = args['phone'];
        // Auto-send OTP if phone was pre-filled
        if (_phoneController.text.length == 10) {
          _sendOTP();
        }
      }
    });
  }

  Future<void> _loadMunicipalities() async {
    final data = await _authService.getMunicipalities();
    if (mounted) {
      setState(() {
        _municipalities = data;
        _loadingMunicipalities = false;
        if (data.isNotEmpty) {
          _selectedMunicipalityId = data[0]['id'] as int?;
        }
      });
    }
  }

  String _getBackendRole(UserRole role) {
    if (role == UserRole.government) return 'municipality_admin';
    if (role == UserRole.provider) return 'provider';
    return 'citizen';
  }

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
          const SnackBar(content: Text("OTP sent successfully")),
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

  Future<void> _verifyAndRegister() async {
    if (_otpController.text.length < 4) return;

    // Validate name and municipality
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your full name"),
          backgroundColor: AppTheme.crimson,
        ),
      );
      return;
    }
    if (_selectedMunicipalityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select your municipality"),
          backgroundColor: AppTheme.crimson,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.verifyOTP(
        phone: _phoneController.text.trim(),
        otp: _otpController.text.trim(),
        name: name,
        role: _getBackendRole(_selectedRole),
        municipality: _selectedMunicipalityId,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
        final appState = AppStateProvider.of(context);
        await appState.setRealUser(user);

        String nextRoute = '/citizen/dashboard';
        if (user.role == UserRole.government) {
          nextRoute = '/gov/dashboard';
        }
        // Providers share the citizen nav (route guards allow both)
        Navigator.pushNamedAndRemoveUntil(context, nextRoute, (_) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration failed. Please try again."),
            backgroundColor: AppTheme.crimson,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
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

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (l == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final lang = LanguageProvider.of(context);

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

                  // Header
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
                  const SizedBox(height: 24),

                  // ── Role Selection ──
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("Citizen"),
                          selected: _selectedRole == UserRole.citizen,
                          onSelected: (_) =>
                              setState(() => _selectedRole = UserRole.citizen),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("Provider"),
                          selected: _selectedRole == UserRole.provider,
                          onSelected: (_) =>
                              setState(() => _selectedRole = UserRole.provider),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Full Name ──
                  TextFormField(
                    controller: _nameController,
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

                  // ── Municipality Dropdown ──
                  _loadingMunicipalities
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text("Loading municipalities..."),
                            ],
                          ),
                        )
                      : DropdownButtonFormField<int>(
                          value: _selectedMunicipalityId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: "Municipality",
                            prefixIcon: Icon(Icons.location_city),
                          ),
                          items: _municipalities.map((m) {
                            return DropdownMenuItem<int>(
                              value: m['id'] as int,
                              child: Text(
                                m['name'] ?? 'Unknown',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedMunicipalityId = val),
                          validator: (val) {
                            if (val == null) return "Select a municipality";
                            return null;
                          },
                        ),
                  const SizedBox(height: 14),

                  if (!_otpSent) ...[
                    // ── Step 1: Phone Number ──
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
                        if (!RegExp(r'^9[5-8]').hasMatch(v)) return "Must start with 95-98";
                        if (v.length != 10) return "Must be 10 digits";
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

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
                    // ── Step 2: OTP Verification ──
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
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _verifyAndRegister,
                              child: Text(l.register),
                            ),
                          ),
                    TextButton(
                      onPressed: () => setState(() => _otpSent = false),
                      child: const Text("Change Phone Number"),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Divider
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
                  const SizedBox(height: 16),

                  // Back to login
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l.alreadyHaveAccount),
                  ),
                  const SizedBox(height: 20),

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
