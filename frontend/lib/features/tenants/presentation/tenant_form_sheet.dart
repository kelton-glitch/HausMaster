import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/events/app_events.dart';
import '../../../core/widgets/form_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/validators.dart';
import '../domain/tenant.dart';
import 'tenants_providers.dart';

/// Create (when [initial] is null) or edit a tenant.
class TenantFormSheet extends ConsumerStatefulWidget {
  const TenantFormSheet({super.key, required this.propertyId, this.initial});

  final int propertyId;
  final Tenant? initial;

  @override
  ConsumerState<TenantFormSheet> createState() => _TenantFormSheetState();
}

class _TenantFormSheetState extends ConsumerState<TenantFormSheet> {
  late final _fullName = TextEditingController(text: widget.initial?.fullName);
  late final _phone = TextEditingController(text: widget.initial?.phone);
  late final _email = TextEditingController(text: widget.initial?.email);
  late final _nationalId = TextEditingController(
    text: widget.initial?.nationalId,
  );
  late final _emergency = TextEditingController(
    text: widget.initial?.emergencyContact,
  );

  bool get _isNew => widget.initial == null;

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _email.dispose();
    _nationalId.dispose();
    _emergency.dispose();
    super.dispose();
  }

  /// An empty box means "not provided", not "an empty string": the API rejects
  /// `""` where it expects a valid value or null (email).
  String? _validateEmail(AppLocalizations l10n, String? v) =>
      (v == null || v.trim().isEmpty) ? null : validateEmail(l10n, v);

  Future<void> _submit() async {
    final repo = ref.read(tenantsRepositoryProvider);
    final fullName = _fullName.text.trim();
    final phone = _phone.text.trim();
    final email = _email.text.trim();
    final nationalId = _nationalId.text.trim();
    final emergency = _emergency.text.trim();
    final id = widget.initial?.id;
    if (id == null) {
      await repo.createTenant(
        widget.propertyId,
        fullName: fullName,
        phone: phone,
        email: email,
        nationalId: nationalId,
        emergencyContact: emergency,
      );
    } else {
      await repo.updateTenant(
        widget.propertyId,
        id,
        fullName: fullName,
        phone: phone,
        email: email,
        nationalId: nationalId,
        emergencyContact: emergency,
      );
    }
    ref.read(appEventsProvider).emit(TenantsChanged(widget.propertyId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormSheet(
      title: _isNew ? l10n.addTenant : l10n.editTenant,
      submitLabel: l10n.save,
      onSubmit: _submit,
      children: [
        TextFormField(
          controller: _fullName,
          autofocus: _isNew,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: l10n.tenantFullName,
            prefixIcon: const Icon(Icons.person_outline),
          ),
          validator: (v) => validateRequired(l10n, v),
        ),
        TextFormField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: l10n.tenantPhone,
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          validator: (v) => validateRequired(l10n, v),
        ),
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: l10n.tenantEmail,
            prefixIcon: const Icon(Icons.mail_outline),
          ),
          validator: (v) => _validateEmail(l10n, v),
        ),
        TextFormField(
          controller: _nationalId,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: l10n.tenantNationalId,
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
        ),
        TextFormField(
          controller: _emergency,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: l10n.tenantEmergencyContact,
            prefixIcon: const Icon(Icons.emergency_outlined),
          ),
        ),
      ],
    );
  }
}
