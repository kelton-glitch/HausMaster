import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../network/failure.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';
import 'error_banner.dart';

/// Opens [sheet] as a modal bottom sheet. Resolves to true if it saved.
Future<bool> showFormSheet(BuildContext context, Widget sheet) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => sheet,
  );
  return saved == true;
}

/// The one form container in the app. Give it fields and an async [onSubmit];
/// it handles validation, the loading button, localized server errors, haptics
/// and keyboard padding identically everywhere. [onSubmit] signals failure by
/// throwing; on success the sheet closes with `true`.
class FormSheet extends StatefulWidget {
  const FormSheet({
    super.key,
    required this.title,
    required this.submitLabel,
    required this.children,
    required this.onSubmit,
  });

  final String title;
  final String submitLabel;
  final List<Widget> children;
  final Future<void> Function() onSubmit;

  @override
  State<FormSheet> createState() => _FormSheetState();
}

class _FormSheetState extends State<FormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  Object? _error;

  Future<void> _submit() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onSubmit();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.sm,
          Spacing.lg,
          Spacing.lg,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              for (final child in widget.children) ...[
                child,
                const SizedBox(height: Spacing.md),
              ],
              if (_error != null) ...[
                ErrorBanner(failureText(context, _error!)),
                const SizedBox(height: Spacing.md),
              ],
              AppButton(
                label: widget.submitLabel,
                loading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
