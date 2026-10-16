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

/// Unified Authentication Page supporting both Phone OTP and Email/Password.
class PhoneEntryPage extends ConsumerStatefulWidget {
  const PhoneEntryPage({super.key});

  @override
  ConsumerState<PhoneEntryPage> createState() => _PhoneEntryPageState();
}

class _PhoneEntryPageState extends ConsumerState<PhoneEntryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Phone controllers & state
  final TextEditingController _phoneController = TextEditingController();
  bool _phoneSubmitting = false;

  // Email controllers & state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isSignUp = false;
  bool _emailSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _emailErrorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitPhone() async {
    if (_phoneSubmitting) {
      return;
    }
    setState(() => _phoneSubmitting = true);
    final AuthState before = ref.read(authControllerProvider);
    await ref
        .read(authControllerProvider.notifier)
        .requestOtp(_phoneController.text);
    if (!mounted) {
      return;
    }
    setState(() => _phoneSubmitting = false);
    final AuthState after = ref.read(authControllerProvider);
    if (before is! AuthOtpRequested && after is AuthOtpRequested) {
      context.go(AppRoutes.otp);
    }
  }

  Future<void> _submitEmail() async {
    if (_emailSubmitting) {
      return;
    }
    setState(() {
      _emailSubmitting = true;
      _emailErrorMessage = null;
    });

    final AppLocalizations l10n = AppLocalizations.of(context);
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String name = _nameController.text.trim();
    final String confirmPassword = _confirmPasswordController.text;

    if (_isSignUp) {
      if (name.isEmpty) {
        setState(() {
          _emailSubmitting = false;
          _emailErrorMessage = l10n.nameInvalid;
        });
        return;
      }
      if (email.isEmpty || !email.contains('@')) {
        setState(() {
          _emailSubmitting = false;
          _emailErrorMessage = l10n.emailInvalid;
        });
        return;
      }
      if (password.length < 6) {
        setState(() {
          _emailSubmitting = false;
          _emailErrorMessage = l10n.passwordInvalid;
        });
        return;
      }
      if (confirmPassword.isNotEmpty && password != confirmPassword) {
        setState(() {
          _emailSubmitting = false;
          _emailErrorMessage = l10n.passwordsDoNotMatch;
        });
        return;
      }
    } else {
      if (email.isEmpty) {
        setState(() {
          _emailSubmitting = false;
          _emailErrorMessage = l10n.emailInvalid;
        });
        return;
      }
      if (password.isEmpty) {
        setState(() {
          _emailSubmitting = false;
          _emailErrorMessage = l10n.passwordInvalid;
        });
        return;
      }
    }

    Result<AuthUser> result;
    if (_isSignUp) {
      result = await ref
          .read(authControllerProvider.notifier)
          .signUpWithEmail(email, password, name: name);
    } else {
      result = await ref
          .read(authControllerProvider.notifier)
          .signInWithEmail(email, password);
    }

    if (!mounted) {
      return;
    }
    setState(() => _emailSubmitting = false);

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
          _emailErrorMessage = failure.message;
        });
      },
    );
  }

  Future<void> _forgotPassword() async {
    final String email = _emailController.text.trim();
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (email.isEmpty || !email.contains('@')) {
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
        .sendPasswordReset(email);

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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final AuthState state = ref.watch(authControllerProvider);
    final String? phoneErrorText = _isInvalidPhone(state) ? l10n.phoneInvalid : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Brand Hero Header
              Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_shipping_rounded,
                    size: 34,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.authTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.authSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Segmented Tabs
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  dividerColor: Colors.transparent,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: <Widget>[
                    Tab(
                      icon: const Icon(Icons.phone_android, size: 20),
                      text: l10n.tabPhone,
                    ),
                    Tab(
                      icon: const Icon(Icons.email_outlined, size: 20),
                      text: l10n.tabEmail,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tab Views
              AnimatedBuilder(
                animation: _tabController,
                builder: (BuildContext context, _) {
                  return _tabController.index == 0
                      ? _buildPhoneSection(l10n, theme, phoneErrorText)
                      : _buildEmailSection(l10n, theme);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneSection(
    AppLocalizations l10n,
    ThemeData theme,
    String? phoneErrorText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.phoneLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('phoneField'),
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: l10n.phoneHint,
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '🇧🇩 +880',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  VerticalDivider(width: 1, indent: 12, endIndent: 12),
                ],
              ),
            ),
            errorText: phoneErrorText,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('phoneContinue'),
          onPressed: _phoneSubmitting ? null : _submitPhone,
          child: _phoneSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.phoneContinue),
        ),
      ],
    );
  }

  Widget _buildEmailSection(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Segmented Header: Sign In vs Sign Up
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  key: const Key('signInSegmentTab'),
                  borderRadius: BorderRadius.circular(8),
                  onTap: _emailSubmitting
                      ? null
                      : () {
                          if (_isSignUp) {
                            setState(() {
                              _isSignUp = false;
                              _emailErrorMessage = null;
                            });
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !_isSignUp
                          ? theme.colorScheme.surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: !_isSignUp
                          ? <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.login_rounded,
                          size: 18,
                          color: !_isSignUp
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.signInAction,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: !_isSignUp
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  key: const Key('signUpSegmentTab'),
                  borderRadius: BorderRadius.circular(8),
                  onTap: _emailSubmitting
                      ? null
                      : () {
                          if (!_isSignUp) {
                            setState(() {
                              _isSignUp = true;
                              _emailErrorMessage = null;
                            });
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _isSignUp
                          ? theme.colorScheme.surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _isSignUp
                          ? <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 18,
                          color: _isSignUp
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.signUpAction,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _isSignUp
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_emailErrorMessage != null) ...<Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _emailErrorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Name field (only for Sign Up)
        if (_isSignUp) ...<Widget>[
          Text(
            l10n.nameLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('nameField'),
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: l10n.nameHint,
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Email / ID field
        Text(
          _isSignUp ? l10n.emailLabel : 'Email or User ID',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('emailField'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: _isSignUp ? l10n.emailHint : 'you@example.com or user ID',
            prefixIcon: const Icon(Icons.alternate_email),
          ),
        ),
        const SizedBox(height: 16),

        // Password field
        Text(
          l10n.passwordLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('passwordField'),
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: l10n.passwordHint,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Confirm Password field (Sign Up only)
        if (_isSignUp) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            l10n.confirmPasswordLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('confirmPasswordField'),
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              hintText: l10n.confirmPasswordHint,
              prefixIcon: const Icon(Icons.lock_reset_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Forgot password link (Sign in mode only)
        if (!_isSignUp) ...<Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _emailSubmitting ? null : _forgotPassword,
              child: Text(l10n.forgotPasswordAction),
            ),
          ),
        ] else
          const SizedBox(height: 12),

        const SizedBox(height: 12),

        // Action submit button
        FilledButton(
          key: const Key('emailSubmitButton'),
          onPressed: _emailSubmitting ? null : _submitEmail,
          child: _emailSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isSignUp ? l10n.signUpAction : l10n.signInAction),
        ),
        const SizedBox(height: 16),

        // Toggle Sign In / Sign Up
        Center(
          child: TextButton(
            key: const Key('toggleAuthModeButton'),
            onPressed: _emailSubmitting
                ? null
                : () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                      _emailErrorMessage = null;
                    });
                  },
            child: Text(
              _isSignUp ? l10n.alreadyHaveAccount : l10n.dontHaveAccount,
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ),

        // Registered Demo Accounts banner (Sign In mode)
        if (!_isSignUp) ...<Widget>[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.vpn_key_outlined,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.registeredDemoAccounts,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: <Widget>[
                    _buildDemoAccountChip('admin@corridorshare.com', 'admin123', 'Admin'),
                    _buildDemoAccountChip('rahim@corridorshare.com', 'password123', 'Rahim'),
                    _buildDemoAccountChip('demo@corridorshare.com', 'demo1234', 'Demo'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDemoAccountChip(String email, String pass, String label) {
    return ActionChip(
      avatar: const Icon(Icons.touch_app_outlined, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        setState(() {
          _emailController.text = email;
          _passwordController.text = pass;
          _emailErrorMessage = null;
        });
      },
    );
  }

  bool _isInvalidPhone(AuthState state) {
    return state is AuthUnauthenticated && state.lastFailure != null;
  }
}