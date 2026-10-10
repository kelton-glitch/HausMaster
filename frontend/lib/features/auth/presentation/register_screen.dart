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
import 'auth_header.dart';
import 'validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password]) {
      c.dispose();
    }
    for (final f in [_emailFocus, _phoneFocus, _passwordFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }
    final navigator = Navigator.of(context);
    setState(() => _loading = true);
    await ref
        .read(authControllerProvider.notifier)
        .register(
          fullName: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          phone: _phone.text.trim(),
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ref.read(authControllerProvider).hasError) {
      HapticFeedback.heavyImpact();
    } else {
      // The root widget swaps to the signed-in view; drop this route.
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createAccount)),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics:
              true, // keyboard-dismiss tap must not be announced
          onTap: () => FocusScope.of(context).unfocus(),
          child: ContentWidth(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Spacing.lg),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthBrand(),
                  const SizedBox(height: Spacing.lg),
                  Text(
                    l10n.registerSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.lg),
                      child: AutofillGroup(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _name,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.name],
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onFieldSubmitted: (_) =>
                                    _emailFocus.requestFocus(),
                                decoration: InputDecoration(
                                  labelText: l10n.fullName,
                                  prefixIcon: const Icon(Icons.person_outline),
                                ),
                                validator: (v) => validateRequired(l10n, v),
                              ),
                              const SizedBox(height: Spacing.md),
                              TextFormField(
                                controller: _email,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.newUsername,
                                ],
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onFieldSubmitted: (_) =>
                                    _phoneFocus.requestFocus(),
                                decoration: InputDecoration(
                                  labelText: l10n.email,
                                  prefixIcon: const Icon(Icons.mail_outline),
                                ),
                                validator: (v) => validateEmail(l10n, v),
                              ),
                              const SizedBox(height: Spacing.md),
                              TextFormField(
                                controller: _phone,
                                focusNode: _phoneFocus,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.telephoneNumber,
                                ],
                                onFieldSubmitted: (_) =>
                                    _passwordFocus.requestFocus(),
                                decoration: InputDecoration(
                                  labelText: l10n.phoneOptional,
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                ),
                              ),
                              const SizedBox(height: Spacing.md),
                              PasswordField(
                                controller: _password,
                                focusNode: _passwordFocus,
                                label: l10n.passwordWithHint,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                                validator: (v) => validateNewPassword(l10n, v),
                              ),
                              const SizedBox(height: Spacing.sm),
                              _PasswordRule(
                                controller: _password,
                                text: l10n.passwordRuleLength,
                              ),
                              if (auth.hasError) ...[
                                const SizedBox(height: Spacing.md),
                                ErrorBanner(failureText(context, auth.error!)),
                              ],
                              const SizedBox(height: Spacing.lg),
                              AppButton(
                                label: l10n.createMyAccount,
                                loading: _loading,
                                onPressed: _submit,
                              ),
                              const SizedBox(height: Spacing.sm),
                              TextButton(
                                onPressed: _loading
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                child: Text(l10n.haveAccount),
                              ),
                            ],
                          ),
                        ),
                      ),
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

/// Live rule hint: turns into a check mark as soon as the password is long enough.
class _PasswordRule extends StatelessWidget {
  const _PasswordRule({required this.controller, required this.text});

  final TextEditingController controller;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final ok = value.text.length >= 8;
        final color = ok ? scheme.primary : scheme.onSurfaceVariant;
        return Semantics(
          label: text,
          value: ok ? '✓' : null,
          excludeSemantics: true,
          child: Row(
            children: [
              Icon(
                ok ? Icons.check_circle : Icons.circle_outlined,
                size: 18,
                color: color,
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: color),
              ),
            ],
          ),
        );
      },
    );
  }
}
