import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/events/app_events.dart';
import '../../../core/widgets/form_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../tenants/domain/tenant.dart';
import '../../units/domain/unit.dart';
import 'leases_providers.dart';

int? _parseInt(String s) => int.tryParse(s.replaceAll(RegExp(r'\s'), ''));

/// Sign a lease. Rent and dates are locked here for good: to change them later,
/// the lease is terminated and a new one signed.
class LeaseFormSheet extends ConsumerStatefulWidget {
  const LeaseFormSheet({
    super.key,
    required this.propertyId,
    required this.units,
    required this.unitTypes,
    required this.tenants,
  });

  final int propertyId;

  /// Only units that can still be leased (the caller filters out occupied ones).
  final List<Unit> units;
  final List<UnitType> unitTypes;
  final List<Tenant> tenants;

  @override
  ConsumerState<LeaseFormSheet> createState() => _LeaseFormSheetState();
}

class _LeaseFormSheetState extends ConsumerState<LeaseFormSheet> {
  late final _rent = TextEditingController();
  late int? _unitId = widget.units.length == 1 ? widget.units.first.id : null;
  late int? _tenantId = widget.tenants.length == 1
      ? widget.tenants.first.id
      : null;
  late DateTime _start = DateTime.now();
  late DateTime _end = DateTime.now().add(const Duration(days: 364));

  /// Once the landlord types their own figure, stop overwriting it from the
  /// unit type's base rent.
  bool _rentEdited = false;

  @override
  void initState() {
    super.initState();
    _rent.text = _baseRentFor(_unitId).toString();
  }

  @override
  void dispose() {
    _rent.dispose();
    super.dispose();
  }

  int _baseRentFor(int? unitId) {
    final unit = widget.units.where((u) => u.id == unitId).firstOrNull;
    final type = widget.unitTypes
        .where((t) => t.id == unit?.unitTypeId)
        .firstOrNull;
    return type?.baseRent ?? 0;
  }

  void _onUnitChanged(int? id) {
    setState(() {
      _unitId = id;
      if (!_rentEdited) _rent.text = _baseRentFor(id).toString();
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart ? _start : _end;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      // An end date can never precede the start date.
      firstDate: isStart
          ? DateTime(now.year - 2)
          : DateTime(_start.year, _start.month, _start.day),
      lastDate: DateTime(now.year + 10, 12, 31),
      helpText: isStart
          ? AppLocalizations.of(context)!.leaseStartDate
          : AppLocalizations.of(context)!.leaseEndDate,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _submit() async {
    await ref
        .read(leasesRepositoryProvider)
        .createLease(
          widget.propertyId,
          unitId: _unitId!,
          tenantId: _tenantId!,
          startDate: _start,
          endDate: _end,
          monthlyRent: _parseInt(_rent.text)!,
        );
    // The lease also moves unit occupancy, so both lists must refresh.
    ref.read(appEventsProvider)
      ..emit(LeasesChanged(widget.propertyId))
      ..emit(UnitsChanged(widget.propertyId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormSheet(
      title: l10n.addLease,
      submitLabel: l10n.save,
      onSubmit: _submit,
      children: [
        DropdownButtonFormField<int>(
          initialValue: _unitId,
          isExpanded: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: l10n.leaseUnit,
            prefixIcon: const Icon(Icons.door_front_door_outlined),
          ),
          items: [
            for (final u in widget.units)
              DropdownMenuItem(value: u.id, child: Text(u.label)),
          ],
          onChanged: _onUnitChanged,
          validator: (v) => v == null ? l10n.fieldRequired : null,
        ),
        DropdownButtonFormField<int>(
          initialValue: _tenantId,
          isExpanded: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: l10n.leaseTenant,
            prefixIcon: const Icon(Icons.person_outline),
          ),
          items: [
            for (final t in widget.tenants)
              DropdownMenuItem(value: t.id, child: Text(t.fullName)),
          ],
          onChanged: (v) => setState(() => _tenantId = v),
          validator: (v) => v == null ? l10n.fieldRequired : null,
        ),
        _DateField(
          label: l10n.leaseStartDate,
          value: _start,
          icon: Icons.event_available_outlined,
          onTap: () => _pickDate(isStart: true),
        ),
        _DateField(
          label: l10n.leaseEndDate,
          value: _end,
          icon: Icons.event_busy_outlined,
          onTap: () => _pickDate(isStart: false),
          error: _end.isBefore(_start) ? l10n.errEndBeforeStart : null,
        ),
        TextFormField(
          controller: _rent,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (_) => _rentEdited = true,
          decoration: InputDecoration(
            labelText: l10n.leaseMonthlyRent,
            helperText: l10n.leaseRentLockedHint,
            prefixIcon: const Icon(Icons.payments_outlined),
          ),
          validator: (v) =>
              _parseInt(v ?? '') == null ? l10n.positiveNumber : null,
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.error,
  });

  final String label;
  final DateTime value;
  final IconData icon;
  final VoidCallback onTap;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          errorText: error,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          l10n.leaseDate(value),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
