import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/events/app_events.dart';
import '../../../core/widgets/form_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/validators.dart';
import '../domain/property.dart';
import 'properties_providers.dart';

/// Create (when [initial] is null) or edit a property.
class PropertyFormSheet extends ConsumerStatefulWidget {
  const PropertyFormSheet({super.key, this.initial});

  final Property? initial;

  @override
  ConsumerState<PropertyFormSheet> createState() => _PropertyFormSheetState();
}

class _PropertyFormSheetState extends ConsumerState<PropertyFormSheet> {
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _address = TextEditingController(text: widget.initial?.address);
  late final _city = TextEditingController(text: widget.initial?.city);

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final repo = ref.read(propertiesRepositoryProvider);
    final name = _name.text.trim();
    final address = _address.text.trim();
    final city = _city.text.trim();
    final initial = widget.initial;
    final saved = initial == null
        ? await repo.create(name: name, address: address, city: city)
        : await repo.update(
            initial.id,
            name: name,
            address: address,
            city: city,
          );
    ref.read(appEventsProvider).emit(PropertyChanged(saved.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormSheet(
      title: widget.initial == null ? l10n.addProperty : l10n.editProperty,
      submitLabel: l10n.save,
      onSubmit: _submit,
      children: [
        TextFormField(
          controller: _name,
          autofocus: widget.initial == null,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: l10n.propertyName,
            prefixIcon: const Icon(Icons.apartment_outlined),
          ),
          validator: (v) => validateRequired(l10n, v),
        ),
        TextFormField(
          controller: _address,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.propertyAddress,
            prefixIcon: const Icon(Icons.place_outlined),
          ),
        ),
        TextFormField(
          controller: _city,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: l10n.propertyCity,
            prefixIcon: const Icon(Icons.location_city_outlined),
          ),
        ),
      ],
    );
  }
}
