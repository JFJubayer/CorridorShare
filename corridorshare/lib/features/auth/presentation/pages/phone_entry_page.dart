import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Unified Authentication Page based on the reference design:
/// - Single unified page (no Phone vs Email tab switcher)
/// - Users can log in using either Email or Phone Number and Password
/// - Fields styled with cool rounded corners (BorderRadius.circular(22))
/// - Create Account button below login form to open sign up
/// - Warm Ivory and Dark Charcoal homepage color theme
/// - Preserves the current brand shipping truck icon header
class PhoneEntryPage extends ConsumerStatefulWidget {
  const PhoneEntryPage({super.key});

  @override
  ConsumerState<PhoneEntryPage> createState() => _PhoneEntryPageState();
}

class _PhoneEntryPageState extends ConsumerState<PhoneEntryPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isSignUp = false;
  bool _submitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final AppLocalizations l10n = AppLocalizations.of(context);
    final String identifier = _identifierController.text.trim();
    final String password = _passwordController.text;
    final String name = _nameController.text.trim();
    final String confirmPassword = _confirmPasswordController.text;

    if (_isSignUp) {
      if (name.isEmpty) {
        setState(() {
          _submitting = false;
          _errorMessage = l10n.nameInvalid;
        });
        return;
      }
      if (identifier.isEmpty) {
        setState(() {
          _submitting = false;
          _errorMessage = l10n.emailInvalid;
        });
        return;
      }
      if (identifier.contains('@') && !identifier.contains('.')) {
        setState(() {
          _submitting = false;
          _errorMessage = l10n.emailInvalid;
        });
        return;
      }
      if (password.length < 6) {
        setState(() {
          _submitting = false;
          _errorMessage = l10n.passwordInvalid;
        });
        return;
      }
      if (confirmPassword.isNotEmpty && password != confirmPassword) {
        setState(() {
          _submitting = false;
          _errorMessage = l10n.passwordsDoNotMatch;
        });
        return;
      }
    } else {
      if (identifier.isEmpty) {
        setState(() {
          _submitting = false;
          _errorMessage = l10n.emailInvalid;
        });
        return;
      }
      if (password.isEmpty) {
        setState(() {
          _submitting = false;
          _errorMessage = l10n.passwordInvalid;
        });
        return;
      }
    }

    Result<AuthUser> result;
    if (_isSignUp) {
      result = await ref
          .read(authControllerProvider.notifier)
          .signUpWithEmail(identifier, password, name: name);
    } else {
      result = await ref
          .read(authControllerProvider.notifier)
          .signInWithEmail(identifier, password);
    }

    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);

    result.fold(
      (AuthUser user) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.home);
        }
      },
      (Failure failure) {
        setState(() {
          _errorMessage = failure.message;
        });
      },
    );
  }

  Future<void> _forgotPassword() async {
    final String identifier = _identifierController.text.trim();
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (identifier.isEmpty || !identifier.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.emailInvalid),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final Result<void> result = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(identifier);

    if (!mounted) {
      return;
    }

    result.fold(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.passwordResetSent),
            backgroundColor: AppColors.success,
          ),
        );
      },
      (Failure failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.danger,
          ),
        );
      },
    );
  }

  void _showSocialNotice(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider sign-in is coming soon for CorridorShare.'),
        backgroundColor: AppColors.darkCharcoal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          l10n.appTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: AppColors.darkCharcoal,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Current Brand Hero Header (Preserved as requested)
              Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.cardBorder,
                      width: 1.2,
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.local_shipping_rounded,
                    size: 34,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title Header
              Text(
                _isSignUp ? l10n.signUpAction : l10n.authTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Text(
                _isSignUp
                    ? 'Sign up to get started with your dashboard.'
                    : 'Explore a modern experience built for speed and simplicity.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.ticketMutedText,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),

              // Error banner if any
              if (_errorMessage != null) ...<Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFF991B1B),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Sign Up / Login Form Fields
              if (_isSignUp) ...<Widget>[
                // Full Name
                _buildFieldLabel(l10n.nameLabel),
                const SizedBox(height: 8),
                _buildInputContainer(
                  child: TextField(
                    key: const Key('nameField'),
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkCharcoal,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(
                        color: Color(0xFF9EA39F),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: AppColors.ticketMutedText,
                      ),
                      border: InputBorder.none,
                      filled: false,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Email or Phone Number Field
              _buildFieldLabel(
                _isSignUp ? 'Email or Phone Number' : 'Email or Phone Number',
              ),
              const SizedBox(height: 8),
              _buildInputContainer(
                child: TextField(
                  key: const Key('emailField'),
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkCharcoal,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter your email or phone number',
                    hintStyle: TextStyle(
                      color: Color(0xFF9EA39F),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.alternate_email,
                      color: AppColors.ticketMutedText,
                    ),
                    border: InputBorder.none,
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              _buildFieldLabel(l10n.passwordLabel),
              const SizedBox(height: 8),
              _buildInputContainer(
                child: TextField(
                  key: const Key('passwordField'),
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkCharcoal,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        _isSignUp ? 'Create a password' : 'Enter your password',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9EA39F),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.ticketMutedText,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.ticketMutedText,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: InputBorder.none,
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              // Confirm Password (Sign Up Mode)
              if (_isSignUp) ...<Widget>[
                const SizedBox(height: 16),
                _buildFieldLabel(l10n.confirmPasswordLabel),
                const SizedBox(height: 8),
                _buildInputContainer(
                  child: TextField(
                    key: const Key('confirmPasswordField'),
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkCharcoal,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Confirm your password',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9EA39F),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_reset_outlined,
                        color: AppColors.ticketMutedText,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.ticketMutedText,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirmPassword =
                              !_obscureConfirmPassword);
                        },
                      ),
                      border: InputBorder.none,
                      filled: false,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],

              // Forgot password link (Login Mode)
              if (!_isSignUp) ...<Widget>[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _submitting ? null : _forgotPassword,
                    child: Text(
                      l10n.forgotPasswordAction,
                      style: const TextStyle(
                        color: AppColors.brand,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ] else
                const SizedBox(height: 16),

              const SizedBox(height: 8),

              // Action Pill Button (Sign In / Create Account)
              SizedBox(
                height: 52,
                child: FilledButton(
                  key: const Key('emailSubmitButton'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.darkCharcoal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isSignUp ? l10n.signUpAction : l10n.signInAction,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Divider "─── Or ───"
              _buildOrDivider(),
              const SizedBox(height: 20),

              // Social Logins Layout matching the reference:
              // Login Mode: Full-width rounded pill buttons
              // Sign Up Mode: Row of 3 circular buttons
              if (!_isSignUp) ...<Widget>[
                _buildSocialPillButton(
                  label: 'Continue with Google',
                  icon: const _GoogleLogo(),
                  onTap: () => _showSocialNotice('Google'),
                ),
                const SizedBox(height: 12),
                _buildSocialPillButton(
                  label: 'Continue with Apple',
                  icon: const Icon(Icons.apple, size: 22, color: Colors.black),
                  onTap: () => _showSocialNotice('Apple'),
                ),
                const SizedBox(height: 12),
                _buildSocialPillButton(
                  label: 'Continue with Facebook',
                  icon: const Icon(
                    Icons.facebook,
                    size: 22,
                    color: Color(0xFF1877F2),
                  ),
                  onTap: () => _showSocialNotice('Facebook'),
                ),
              ] else ...<Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildCircularSocialButton(
                      icon: const _GoogleLogo(),
                      onTap: () => _showSocialNotice('Google'),
                    ),
                    const SizedBox(width: 18),
                    _buildCircularSocialButton(
                      icon: const Icon(
                        Icons.apple,
                        size: 22,
                        color: Colors.black,
                      ),
                      onTap: () => _showSocialNotice('Apple'),
                    ),
                    const SizedBox(width: 18),
                    _buildCircularSocialButton(
                      icon: const Icon(
                        Icons.facebook,
                        size: 22,
                        color: Color(0xFF1877F2),
                      ),
                      onTap: () => _showSocialNotice('Facebook'),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // "Create Account button should be below it, upon clicking it opens sign up form"
              if (!_isSignUp) ...<Widget>[
                Center(
                  child: TextButton(
                    key: const Key('toggleAuthModeButton'),
                    onPressed: _submitting
                        ? null
                        : () {
                            setState(() {
                              _isSignUp = true;
                              _errorMessage = null;
                            });
                          },
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.ticketMutedText,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.brand,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...<Widget>[
                Center(
                  child: TextButton(
                    key: const Key('toggleAuthModeButton'),
                    onPressed: _submitting
                        ? null
                        : () {
                            setState(() {
                              _isSignUp = false;
                              _errorMessage = null;
                            });
                          },
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.ticketMutedText,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.brand,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // Registered Demo Accounts Banner (Quick testing access)
              if (!_isSignUp) ...<Widget>[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bannerBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.cardBorder,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.vpn_key_outlined,
                            size: 16,
                            color: AppColors.brand,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.registeredDemoAccounts,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: <Widget>[
                          _buildDemoAccountChip(
                            'admin@corridorshare.com',
                            'admin123',
                            'Admin',
                          ),
                          _buildDemoAccountChip(
                            'rahim@corridorshare.com',
                            'password123',
                            'Rahim',
                          ),
                          _buildDemoAccountChip(
                            'demo@corridorshare.com',
                            'demo1234',
                            'Demo',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.darkCharcoal,
        letterSpacing: -0.1,
      ),
    );
  }

  /// Input container with cool rounded radius (22px)
  Widget _buildInputContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1.2,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildOrDivider() {
    return const Row(
      children: <Widget>[
        Expanded(
          child: Divider(
            color: AppColors.cardBorder,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ticketMutedText,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.cardBorder,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialPillButton({
    required String label,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1.2,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              icon,
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularSocialButton({
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1.2,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(child: icon),
        ),
      ),
    );
  }

  Widget _buildDemoAccountChip(String email, String pass, String label) {
    return ActionChip(
      avatar: const Icon(
        Icons.touch_app_outlined,
        size: 14,
        color: AppColors.darkCharcoal,
      ),
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColors.cardBorder, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.darkCharcoal,
        ),
      ),
      onPressed: () {
        setState(() {
          _identifierController.text = email;
          _passwordController.text = pass;
          _errorMessage = null;
        });
      },
    );
  }
}

/// Official 4-color Google G icon painter
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w / 2;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22
      ..strokeCap = StrokeCap.butt;

    final Rect rect = Rect.fromCircle(
      center: Offset(cx, cy),
      radius: r - paint.strokeWidth / 2,
    );

    // Blue arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.6, 1.2, false, paint);

    // Green arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.6, 1.2, false, paint);

    // Yellow arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 1.8, 1.2, false, paint);

    // Red arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.0, 1.5, false, paint);

    // Horizontal blue bar
    final Paint barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final double barH = paint.strokeWidth;
    canvas.drawRect(
      Rect.fromLTWH(cx - 1, cy - barH / 2, r * 0.95, barH),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}