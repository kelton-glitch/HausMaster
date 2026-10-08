import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/failure.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/password_field.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_controller.dart';
import 'register_screen.dart';
import 'validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }
    setState(() => _loading = true);
    await ref
        .read(authControllerProvider.notifier)
        .login(_email.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ref.read(authControllerProvider).hasError) HapticFeedback.heavyImpact();
  }

  Future<void> _openRegister() async {
    ref.read(authControllerProvider.notifier).clearError();
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
    if (mounted) ref.read(authControllerProvider.notifier).clearError();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics:
              true, // keyboard-dismiss tap must not be announced
          onTap: () => FocusScope.of(context).unfocus(),
          child: ContentWidth(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.lg),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                        Semantics(
                          header: true,
                          child: Text(
                            'HausMaster',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: Spacing.lg),
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.loginTitle,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          l10n.loginSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: Spacing.xl),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onFieldSubmitted: (_) =>
                              _passwordFocus.requestFocus(),
                          decoration: InputDecoration(
                            labelText: l10n.email,
                            prefixIcon: const Icon(Icons.mail_outline),
                          ),
                          validator: (v) => validateEmail(l10n, v),
                        ),
                        const SizedBox(height: Spacing.md),
                        PasswordField(
                          controller: _password,
                          focusNode: _passwordFocus,
                          label: l10n.password,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          validator: (v) => validateRequired(l10n, v),
                        ),
                        if (auth.hasError) ...[
                          const SizedBox(height: Spacing.md),
                          ErrorBanner(failureText(context, auth.error!)),
                        ],
                        const SizedBox(height: Spacing.lg),
                        AppButton(
                          label: l10n.login,
                          loading: _loading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: Spacing.sm),
                        TextButton(
                          onPressed: _loading ? null : _openRegister,
                          child: Text(l10n.createAccount),
                        ),
                      ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
