import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:health_ai/core/theme/app_theme.dart';
import 'package:health_ai/core/firebase/firebase_config.dart';
import 'package:health_ai/features/auth/data/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Layout
  static const double _wideBreakpoint = 900;
  static const double _sheetRadius = 28;
  static const String _heroImage = 'assets/image1.jpg';

  // Palette (same as login)
  static const Color _pageBg = Color(0xFFF7F8FB);
  static const Color _fieldBg = Color(0xFFF3F4F8);
  static const Color _border = Color(0xFFE2E5EC);
  static const Color _icon = Color(0xFF8A90A0);
  static const Color _error = Color(0xFFC62828);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _pinFocus = FocusNode();
  final _confirmFocus = FocusNode();
  AuthRepository? _authRepository;

  bool _isLoading = false;
  bool _isInitializing = true;
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;
  String? _errorMessage;
  String _selectedRole = 'Nurse';

  final List<String> _roles = const [
    'Nurse',
    'Clinical Officer',
    'Medical Officer',
    'Midwife',
    'Lab Technician',
    'Administrator',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      if (Firebase.apps.isEmpty) {
        await FirebaseConfig.initialize();
      }
      _authRepository = AuthRepository();
      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Failed to initialize auth. Please restart the app.';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _phoneFocus.dispose();
    _pinFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  String _normalizedPhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return digits;
  }

  bool _isWeakPin(String pin) {
    if (RegExp(r'^(\d)\1{3}$').hasMatch(pin)) return true; // 1111, 0000
    return const {'1234', '4321', '0123', '3210', '2580', '1212'}.contains(pin);
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_authRepository == null) {
      setState(() {
        _errorMessage = 'Authentication not ready. Please restart the app.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phone = _normalizedPhone(_phoneController.text);
      final email = '$phone@nsiika.health';
      // Firebase requires 6+ char passwords, so the PIN is prefixed.
      final password = 'PIN${_pinController.text}';

      await _authRepository!.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: _nameController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2E7D32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text('Account created successfully'),
        ),
      );
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } catch (e) {
      if (!mounted) return;
      final text = e.toString();
      final lower = text.toLowerCase();
      String msg;
      if (text.contains('email-already-in-use')) {
        msg = 'This phone number is already registered. Try signing in instead.';
      } else if (lower.contains('weak-password') || text.contains('WEAK_PASSWORD')) {
        msg = 'That PIN is too weak. Please choose a different one.';
      } else if (text.contains('invalid-email')) {
        msg = 'That phone number format is not valid.';
      } else if (lower.contains('network')) {
        msg = 'No internet connection. Check your network and try again.';
      } else {
        msg = 'Registration failed. Please try again.';
      }
      debugPrint('Registration error: $e');
      setState(() {
        _errorMessage = msg;
        _isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    // Show loading screen while initializing Firebase
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: _pageBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 24),
              Text(
                'Initializing...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.greyText,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: _pageBg,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, c) =>
              c.maxWidth >= _wideBreakpoint ? _buildWide() : _buildNarrow(c),
        ),
      ),
    );
  }

  Widget _buildNarrow(BoxConstraints c) {
    final topPad = MediaQuery.of(context).padding.top;
    final headerH = topPad + (c.maxHeight * 0.22).clamp(130.0, 210.0);
    final sheetMinH = (c.maxHeight - headerH).clamp(0.0, double.infinity);

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerH + _sheetRadius + 8,
          child: _hero(),
        ),
        SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              SizedBox(
                height: headerH,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, topPad + 8, 24, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Back',
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                        const SizedBox(width: 4),
                        _brandRow(),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                constraints: BoxConstraints(minHeight: sheetMinH),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(_sheetRadius),
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: _formContent(showBack: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWide() {
    return Row(
      children: [
        Expanded(
          flex: 11,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _hero(),
              Padding(
                padding: const EdgeInsets.all(56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _brandRow(),
                    const Spacer(),
                    const Text(
                      'Join the\nNsiika health team.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _featureLine('Record visits and facility conditions in one place'),
                    _featureLine('See which patients need attention first'),
                    _featureLine('Works even when the internet is unreliable'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 9,
          child: Container(
            color: Colors.white,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _formContent(showBack: true),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------- shared parts

  Widget _hero() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _heroImage,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.darkPurple.withValues(alpha: 0.72),
                Colors.black.withValues(alpha: 0.78),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _brandRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: const Icon(Icons.health_and_safety_rounded,
              color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              'Nsiika Health Centre IV',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _featureLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration({
    String? hint,
    Widget? prefix,
    Widget? suffix,
    BoxConstraints? prefixConstraints,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA0A6B4), letterSpacing: 0.3),
      filled: true,
      fillColor: _fieldBg,
      counterText: '',
      prefixIcon: prefix,
      prefixIconConstraints: prefixConstraints,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: border(_border),
      focusedBorder: border(AppTheme.darkPurple, 1.6),
      errorBorder: border(_error),
      focusedErrorBorder: border(_error, 1.6),
      errorStyle: const TextStyle(fontSize: 12, height: 1.3),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkText,
            letterSpacing: 0.2,
          ),
        ),
      );

  Widget _pinSuffix(bool obscured, VoidCallback onTap) => IconButton(
        tooltip: obscured ? 'Show PIN' : 'Hide PIN',
        icon: Icon(
          obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: _icon,
          size: 22,
        ),
        onPressed: onTap,
      );

  Widget _formContent({required bool showBack}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showBack) ...[
          TextButton.icon(
            onPressed: () => Navigator.maybePop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppTheme.darkPurple,
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text(
              'Back to sign in',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 20),
        ],
        const Text(
          'Create your account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.darkText,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Register as a member of the Nsiika health team.',
          style: TextStyle(fontSize: 14.5, height: 1.4, color: AppTheme.greyText),
        ),
        const SizedBox(height: 28),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full name
              _label('Full name'),
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                style: const TextStyle(fontSize: 16),
                decoration: _decoration(
                  hint: 'e.g. Sarah Atuhaire',
                  prefix: const Icon(Icons.person_outline_rounded,
                      color: _icon, size: 22),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  if (v.trim().length < 3) return 'Name looks too short';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Role
              _label('Role'),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _selectedRole,
                isExpanded: true,
                borderRadius: BorderRadius.circular(14),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _icon),
                style: const TextStyle(fontSize: 16, color: AppTheme.darkText),
                decoration: _decoration(
                  prefix: const Icon(Icons.work_outline_rounded,
                      color: _icon, size: 22),
                ),
                items: _roles
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedRole = v);
                },
              ),
              const SizedBox(height: 20),

              // Phone
              _label('Phone number'),
              TextFormField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (_) => _pinFocus.requestFocus(),
                style: const TextStyle(fontSize: 16, letterSpacing: 0.5),
                decoration: _decoration(
                  hint: '700 000 000',
                  prefixConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '+256',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(width: 1, height: 22, color: _border),
                      ],
                    ),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (_normalizedPhone(v).length != 9) {
                    return 'Enter a valid 9-digit number, e.g. 700 000 000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // PIN
              _label('Create a 4-digit PIN'),
              TextFormField(
                controller: _pinController,
                focusNode: _pinFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                maxLength: 4,
                obscureText: _obscurePin,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                style: const TextStyle(fontSize: 18, letterSpacing: 6),
                decoration: _decoration(
                  hint: '••••',
                  prefix: const Icon(Icons.lock_outline_rounded,
                      color: _icon, size: 22),
                  suffix: _pinSuffix(_obscurePin,
                      () => setState(() => _obscurePin = !_obscurePin)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please create a PIN';
                  if (v.length != 4) return 'PIN must be 4 digits';
                  if (_isWeakPin(v)) {
                    return 'Choose a less obvious PIN (avoid 1234 or 1111)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Confirm PIN
              _label('Confirm PIN'),
              TextFormField(
                controller: _confirmPinController,
                focusNode: _confirmFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 4,
                obscureText: _obscureConfirmPin,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (_) {
                  // Just unfocus, don't auto-submit
                  FocusScope.of(context).unfocus();
                },
                style: const TextStyle(fontSize: 18, letterSpacing: 6),
                decoration: _decoration(
                  hint: '••••',
                  prefix: const Icon(Icons.lock_outline_rounded,
                      color: _icon, size: 22),
                  suffix: _pinSuffix(
                      _obscureConfirmPin,
                      () => setState(
                          () => _obscureConfirmPin = !_obscureConfirmPin)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please confirm your PIN';
                  if (v != _pinController.text) return 'PINs do not match';
                  return null;
                },
              ),
            ],
          ),
        ),

        // Error banner
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _errorMessage == null
              ? const SizedBox(width: double.infinity)
              : Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 18),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDECEC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF5C2C2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: _error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: _error, fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkPurple,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppTheme.darkPurple.withValues(alpha: 0.7),
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Create account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Already have an account?',
                style: TextStyle(fontSize: 14, color: AppTheme.greyText),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.maybePop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Sign in',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkPurple,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        const Divider(color: _border, height: 1),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.verified_user_outlined, size: 16, color: _icon),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'By creating an account, you agree to follow Nsiika Health Centre '
                'policies and keep patient information confidential.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: AppTheme.greyText,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}