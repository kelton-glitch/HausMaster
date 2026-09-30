import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/events/app_events.dart';
import '../../../core/widgets/form_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/validators.dart';
import '../domain/unit.dart';
import 'units_providers.dart';

int? _parseInt(String s) => int.tryParse(s.replaceAll(RegExp(r'\s'), ''));

/// Create (when [initial] is null) or edit a unit type.
class UnitTypeFormSheet extends ConsumerStatefulWidget {
  const UnitTypeFormSheet({super.key, required this.propertyId, this.initial});

  final int propertyId;
  final UnitType? initial;

  @override
  ConsumerState<UnitTypeFormSheet> createState() => _UnitTypeFormSheetState();
}

class _UnitTypeFormSheetState extends ConsumerState<UnitTypeFormSheet> {
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _rooms = TextEditingController(
    text: widget.initial?.roomCount.toString(),
  );
  late final _rent = TextEditingController(
    text: widget.initial?.baseRent.toString(),
  );

  @override
  void dispose() {
    _name.dispose();
    _rooms.dispose();
    _rent.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final repo = ref.read(unitsRepositoryProvider);
    final initial = widget.initial;
    final name = _name.text.trim();
    final rooms = _parseInt(_rooms.text)!;
    final rent = _parseInt(_rent.text)!;
    if (initial == null) {
      await repo.createUnitType(
        widget.propertyId,
        name: name,
        roomCount: rooms,
        baseRent: rent,
      );
    } else {
      await repo.updateUnitType(
        widget.propertyId,
        initial.id,
        name: name,
        roomCount: rooms,
        baseRent: rent,
      );
    }
    ref.read(appEventsProvider).emit(UnitsChanged(widget.propertyId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormSheet(
      title: widget.initial == null ? l10n.addUnitType : l10n.editUnitType,
      submitLabel: l10n.save,
      onSubmit: _submit,
      children: [
        TextFormField(
          controller: _name,
          autofocus: widget.initial == null,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: l10n.unitTypeName,
            prefixIcon: const Icon(Icons.category_outlined),
          ),
          validator: (v) => validateRequired(l10n, v),
        ),
        TextFormField(
          controller: _rooms,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: l10n.roomCount,
            prefixIcon: const Icon(Icons.meeting_room_outlined),
          ),
          validator: (v) {
            final n = _parseInt(v ?? '');
            return (n == null || n < 1 || n > 100) ? l10n.positiveNumber : null;
          },
        ),
        TextFormField(
          controller: _rent,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: l10n.baseRent,
            prefixIcon: const Icon(Icons.payments_outlined),
          ),
          validator: (v) =>
              _parseInt(v ?? '') == null ? l10n.positiveNumber : null,
        ),
      ],
    );
  }
}
