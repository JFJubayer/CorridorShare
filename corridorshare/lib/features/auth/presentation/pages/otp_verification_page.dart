import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final TextEditingController _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    setState(() => _submitting = true);
    await ref.read(authControllerProvider.notifier).verifyOtp(_controller.text);
    if (mounted) {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AuthState state = ref.watch(authControllerProvider);
    final String phoneDisplay = switch (state) {
      AuthOtpRequested() => _formatPhone(state.phone),
      _ => '',
    };
    final String? errorText =
        state is AuthOtpRequested && state.lastFailure != null
            ? l10n.otpInvalid
            : null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 24),
              Text(
                l10n.otpTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(phoneDisplay, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              TextField(
                key: const Key('otpField'),
                controller: _controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: l10n.otpHint,
                  errorText: errorText,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('otpVerify'),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.otpVerify),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _submitting
                    ? null
                    : () => ref
                        .read(authControllerProvider.notifier)
                        .requestOtp(phoneDisplay),
                child: Text(l10n.otpResend),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPhone(String input) {
    if (input.startsWith('+8801') && input.length == 14) {
      return '+880 ${input.substring(4, 7)} ${input.substring(7)}';
    }
    if (input.startsWith('01') && input.length == 11) {
      return '+880 ${input.substring(1, 4)} ${input.substring(4)}';
    }
    return input;
  }
}