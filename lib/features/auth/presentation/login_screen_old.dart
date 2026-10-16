import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_ai/core/theme/app_theme.dart';
import 'package:health_ai/features/auth/data/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Layout
  static const double _wideBreakpoint = 900;
  static const double _sheetRadius = 28;
  static const String _heroImage = 'assets/image1.jpg';

  // Palette (neutral surfaces, brand colour only for actions)
  static const Color _pageBg = Color(0xFFF7F8FB);
  static const Color _fieldBg = Color(0xFFF3F4F8);
  static const Color _border = Color(0xFFE2E5EC);
  static const Color _error = Color(0xFFC62828);

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _pinFocus = FocusNode();
  final _authRepository = AuthRepository();

  bool _isLoading = false;
  bool _obscurePin = true;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  /// Accepts "700000000" or "0700000000" and returns the 9 digit form.
  String _normalizedPhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return digits;
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phone = _normalizedPhone(_phoneController.text);
      final email = '$phone@nsiika.health';
      // Firebase requires 6+ char passwords, so the PIN is prefixed.
      final password = 'PIN${_pinController.text}';

      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } catch (e) {
      if (!mounted) return;
      final text = e.toString().toLowerCase();
      setState(() {
        _errorMessage = text.contains('network')
            ? 'No internet connection. Check your network and try again.'
            : 'Invalid phone number or PIN. Please try again.';
        _isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, c) =>
              c.maxWidth >= _wideBreakpoint ? _buildWide(c) : _buildNarrow(c),
        ),
      ),
    );
  }

  // Phones and small tablets: photo header + rounded white sheet.
  Widget _buildNarrow(BoxConstraints c) {
    final topPad = MediaQuery.of(context).padding.top;
    final headerH = topPad + (c.maxHeight * 0.26).clamp(150.0, 260.0);
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
                  padding: EdgeInsets.fromLTRB(24, topPad + 16, 24, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: _brandRow(),
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
                    child: _formContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Tablets landscape, desktop, web: brand panel left, form right.
  Widget _buildWide(BoxConstraints c) {
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
                      'Anticipate risk.\nAct early.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _featureLine('Predict patient risk before complications occur'),
                    _featureLine('Track staffing, stock-outs and referral delays'),
                    _featureLine('Clear recommendations your team can act on'),
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
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _formContent(),
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
          child: const Icon(
            Icons.health_and_safety_rounded,
            color: Colors.white,
            size: 24,
          ),
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
    required String hint,
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

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.darkText,
          letterSpacing: 0.2,
        ),
      );

  Widget _formContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.darkText,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in with your phone number and PIN to continue.',
          style: TextStyle(fontSize: 14.5, height: 1.4, color: AppTheme.greyText),
        ),
        const SizedBox(height: 28),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Phone number'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (_normalizedPhone(value).length != 9) {
                    return 'Enter a valid 9-digit number, e.g. 700 000 000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _label('4-digit PIN'),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppTheme.darkPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          content: const Text(
                            'Contact your administrator to reset your PIN.',
                          ),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Forgot PIN?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkPurple,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _pinController,
                focusNode: _pinFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 4,
                obscureText: _obscurePin,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (_) => _isLoading ? null : _handleLogin(),
                style: const TextStyle(fontSize: 18, letterSpacing: 6),
                decoration: _decoration(
                  hint: '••••',
                  prefix: const Icon(Icons.lock_outline_rounded,
                      color: Color(0xFF8A90A0), size: 22),
                  suffix: IconButton(
                    tooltip: _obscurePin ? 'Show PIN' : 'Hide PIN',
                    icon: Icon(
                      _obscurePin
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF8A90A0),
                      size: 22,
                    ),
                    onPressed: () => setState(() => _obscurePin = !_obscurePin),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your PIN';
                  }
                  if (value.length != 4) return 'PIN must be 4 digits';
                  return null;
                },
              ),
            ],
          ),
        ),

        // Error banner (animates in and out)
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
                            color: _error,
                            fontSize: 13,
                            height: 1.4,
                          ),
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
            onPressed: _isLoading ? null : _handleLogin,
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
                    'Sign in',
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
                'New health worker?',
                style: TextStyle(fontSize: 14, color: AppTheme.greyText),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/register'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Create account',
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
            const Icon(Icons.info_outline_rounded,
                size: 16, color: Color(0xFF8A90A0)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Decision-support only. Does not replace clinical judgement.',
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