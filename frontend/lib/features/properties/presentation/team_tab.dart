import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/events/app_events.dart';
import '../../../core/format.dart';
import '../../../core/network/failure.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/form_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/validators.dart';
import '../domain/policy.dart';
import '../domain/property.dart';
import 'properties_providers.dart';
import 'role_badge.dart';

/// Who has access to this property (FR-04). Owners can invite and remove.
class TeamTab extends ConsumerWidget {
  const TeamTab({super.key, required this.propertyId, required this.canManage});

  final int propertyId;
  final bool canManage;

  Future<void> _invite(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final saved = await showFormSheet(
      context,
      _InviteSheet(propertyId: propertyId),
    );
    if (saved && context.mounted) showSnack(context, l10n.inviteSent);
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    AccessEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await confirmAction(
      context,
      title: l10n.removeAccessTitle,
      body: l10n.removeAccessBody,
      confirmLabel: l10n.removeAccess,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref
          .read(propertiesRepositoryProvider)
          .revokeAccess(propertyId, entry.managerId);
      ref.read(appEventsProvider).emit(AccessChanged(propertyId));
      if (context.mounted) showSnack(context, l10n.accessRemoved);
    } catch (e) {
      if (context.mounted) showSnack(context, failureText(context, e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final me = ref.watch(authControllerProvider).value?.id;
    final access = ref.watch(accessProvider(propertyId));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AsyncView<List<AccessEntry>>(
        value: access,
        onRefresh: () => ref.refresh(accessProvider(propertyId).future),
        data: (list) => ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.md,
            Spacing.lg,
            96,
          ),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final e = list[i];
            final isMe = e.managerId == me;
            return Card(
              margin: const EdgeInsets.only(bottom: Spacing.sm),
              child: ListTile(
                isThreeLine: true,
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    initialsOf(e.fullName),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                title: Text(isMe ? '${e.fullName} (${l10n.you})' : e.fullName),
                // Badge goes under the email; only the (fixed-size) remove
                // button is trailing, so long names/emails can't overflow.
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.email, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: Spacing.xs),
                    RoleBadge(e.role),
                  ],
                ),
                trailing: canManage && !isMe
                    ? IconButton(
                        tooltip: l10n.removeAccess,
                        icon: const Icon(Icons.person_remove_outlined),
                        onPressed: () => _remove(context, ref, e),
                      )
                    : null,
              ),
            );
          },
        ),
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _invite(context),
              icon: const Icon(Icons.person_add_alt_outlined),
              label: Text(l10n.inviteManager),
            )
          : null,
    );
  }
}

class _InviteSheet extends ConsumerStatefulWidget {
  const _InviteSheet({required this.propertyId});

  final int propertyId;

  @override
  ConsumerState<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<_InviteSheet> {
  final _email = TextEditingController();
  Role _role = Role.coManager;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref
        .read(propertiesRepositoryProvider)
        .grantAccess(widget.propertyId, email: _email.text.trim(), role: _role);
    ref.read(appEventsProvider).emit(AccessChanged(widget.propertyId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FormSheet(
      title: l10n.inviteManager,
      submitLabel: l10n.invite,
      onSubmit: _submit,
      children: [
        TextFormField(
          controller: _email,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: l10n.email,
            helperText: l10n.inviteEmailHelp,
            prefixIcon: const Icon(Icons.mail_outline),
          ),
          validator: (v) => validateEmail(l10n, v),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.inviteRole,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: Spacing.sm),
            SegmentedButton<Role>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: Role.coManager,
                  label: Text(l10n.roleCoManager),
                ),
                ButtonSegment(value: Role.owner, label: Text(l10n.roleOwner)),
              ],
              selected: {_role},
              onSelectionChanged: (s) => setState(() => _role = s.first),
            ),
          ],
        ),
      ],
    );
  }
}
