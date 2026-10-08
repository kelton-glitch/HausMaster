/// Client mirror of the backend permission policy (`app/core/policy.py`).
/// The server is authoritative; this only decides which controls to *show*.
enum Role {
  owner('owner'),
  coManager('co_manager');

  const Role(this.value);
  final String value;

  static Role fromJson(String value) =>
      Role.values.firstWhere((r) => r.value == value, orElse: () => coManager);
}

enum PropertyAction {
  view,
  edit,
  deactivate,
  manageAccess,
  manageUnits,
  manageTenants,
  manageLeases,
}

const _policy = <Role, Set<PropertyAction>>{
  Role.owner: {...PropertyAction.values},
  Role.coManager: {
    PropertyAction.view,
    PropertyAction.manageUnits,
    PropertyAction.manageTenants,
    PropertyAction.manageLeases,
  },
};

bool can(Role role, PropertyAction action) => _policy[role]!.contains(action);
