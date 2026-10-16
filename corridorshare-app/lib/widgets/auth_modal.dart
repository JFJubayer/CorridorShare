import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../providers/user_provider.dart';
import 'ui.dart';

class AuthModal extends StatefulWidget {
  const AuthModal({super.key});

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;
  String? _error;

  Future<void> _sendOtp() async {
    if (_phoneController.text.trim().isEmpty) {
      setState(() => _error = 'Enter your mobile number.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .requestOtp(_phoneController.text);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _otpSent = true;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '$error';
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length < 6) {
      setState(() => _error = 'Enter the six-digit code.');
      return;
    }
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await userProvider.verifyOtp(
        phone: _phoneController.text,
        otp: _otpController.text,
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '$error';
      });
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signed in.')),
    );
  }

  void _startDemoSession() {
    try {
      Provider.of<UserProvider>(context, listen: false)
          .startDemoSession(_phoneController.text);
      Navigator.of(context).pop();
    } on Object catch (error) {
      setState(() => _error = '$error');
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
    final isDemo = Provider.of<UserProvider>(context).dataMode.name == 'demo';
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_otpSent ? 'Enter the code' : 'Sign in',
                  style: context.tt.headlineSmall),
              Gap.xs,
              Text(
                _otpSent
                    ? 'We sent a six-digit code to ${_phoneController.text.trim()}.'
                    : 'We will text a one-time code to your Bangladesh mobile number.',
                style: context.tt.bodyMedium,
              ),
              Gap.lg,
              if (!_otpSent)
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _sendOtp(),
                  decoration: InputDecoration(
                    labelText: 'Mobile number',
                    helperText: 'Include the country code, e.g. +8801XXXXXXXXX',
                    errorText: _error,
                  ),
                )
              else
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _verifyOtp(),
                  style: context.tt.headlineSmall?.copyWith(letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText: '••••••',
                    counterText: '',
                    errorText: _error,
                  ),
                ),
              Gap.lg,
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      _isLoading ? null : (_otpSent ? _verifyOtp : _sendOtp),
                  child: _isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.cs.onSurfaceVariant,
                          ),
                        )
                      : Text(_otpSent ? 'Verify and sign in' : 'Send code'),
                ),
              ),
              if (_otpSent) ...[
                Gap.sm,
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() {
                              _otpSent = false;
                              _error = null;
                              _otpController.clear();
                            }),
                    child: const Text('Use a different number'),
                  ),
                ),
              ],
              if (isDemo && !_otpSent) ...[
                Gap.sm,
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _startDemoSession,
                    child: const Text('Continue in demo mode'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
