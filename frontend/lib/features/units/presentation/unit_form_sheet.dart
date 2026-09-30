import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/events/app_events.dart';
import '../../../core/widgets/form_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/validators.dart';
import '../domain/unit.dart';
import 'units_providers.dart';

/// Create (when [initial] is null) or edit a unit.
class UnitFormSheet extends ConsumerStatefulWidget {
  const UnitFormSheet({
    super.key,
    required this.propertyId,
    required this.unitTypes,
    this.initial,
  });

  final int propertyId;

  /// Active unit types the user can pick from.
  final List<UnitType> unitTypes;
  final Unit? initial;

  @override
  ConsumerState<UnitFormSheet> createState() => _UnitFormSheetState();
}

class _UnitFormSheetState extends ConsumerState<UnitFormSheet> {
  late final _label = TextEditingController(text: widget.initial?.label);
  late int? _typeId =
      widget.initial?.unitTypeId ??
      (widget.unitTypes.length == 1 ? widget.unitTypes.first.id : null);

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final repo = ref.read(unitsRepositoryProvider);
    final initial = widget.initial;
    if (initial == null) {
      await repo.createUnit(
        widget.propertyId,
        label: _label.text.trim(),
        unitTypeId: _typeId!,
      );
    } else {
      await repo.updateUnit(
        widget.propertyId,
        initial.id,
        label: _label.text.trim(),
        unitTypeId: _typeId!,
      );
    }
    ref.read(appEventsProvider).emit(UnitsChanged(widget.propertyId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final initial = widget.initial;
    // A unit may still use a since-deactivated type: keep it selectable.
    final items = [
      for (final t in widget.unitTypes) (t.id, t.name),
      if (initial != null &&
          !widget.unitTypes.any((t) => t.id == initial.unitTypeId))
        (initial.unitTypeId, initial.unitTypeName),
    ];
    return FormSheet(
      title: initial == null ? l10n.addUnit : l10n.editUnit,
      submitLabel: l10n.save,
      onSubmit: _submit,
      children: [
        TextFormField(
          controller: _label,
          autofocus: initial == null,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: l10n.unitLabel,
            prefixIcon: const Icon(Icons.door_front_door_outlined),
          ),
          validator: (v) => validateRequired(l10n, v),
        ),
        DropdownButtonFormField<int>(
          initialValue: _typeId,
          isExpanded: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: l10n.unitType,
            prefixIcon: const Icon(Icons.category_outlined),
          ),
          items: [
            for (final (id, name) in items)
              DropdownMenuItem(value: id, child: Text(name)),
          ],
          onChanged: (v) => setState(() => _typeId = v),
          validator: (v) => v == null ? l10n.fieldRequired : null,
        ),
      ],
    );
  }
}
