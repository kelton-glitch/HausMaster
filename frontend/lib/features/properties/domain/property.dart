import 'policy.dart';

class Property {
  const Property({
    required this.id,
    required this.name,
    this.address,
    this.city,
    required this.isActive,
    required this.role,
    required this.unitCount,
    required this.occupiedCount,
  });

  final int id;
  final String name;
  final String? address;
  final String? city;
  final bool isActive;

  /// The signed-in manager's role on this property.
  final Role role;
  final int unitCount;
  final int occupiedCount;

  bool can(PropertyAction action) => _can(role, action);

  /// "Address, City" with whichever parts exist.
  String? get location {
    final parts = [
      address,
      city,
    ].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? null : parts.join(', ');
  }

  factory Property.fromJson(Map<String, dynamic> json) => Property(
    id: json['id'] as int,
    name: json['name'] as String,
    address: json['address'] as String?,
    city: json['city'] as String?,
    isActive: json['is_active'] as bool,
    role: Role.fromJson(json['role'] as String),
    unitCount: json['unit_count'] as int,
    occupiedCount: json['occupied_count'] as int,
  );
}

bool _can(Role role, PropertyAction action) => can(role, action);

class AccessEntry {
  const AccessEntry({
    required this.managerId,
    required this.fullName,
    required this.email,
    required this.role,
  });

  final int managerId;
  final String fullName;
  final String email;
  final Role role;

  factory AccessEntry.fromJson(Map<String, dynamic> json) => AccessEntry(
    managerId: json['manager_id'] as int,
    fullName: json['full_name'] as String,
    email: json['email'] as String,
    role: Role.fromJson(json['role'] as String),
  );
}
