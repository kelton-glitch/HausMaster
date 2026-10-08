class Tenant {
  const Tenant({
    required this.id,
    required this.propertyId,
    required this.fullName,
    required this.phone,
    required this.isActive,
    this.email,
    this.nationalId,
    this.emergencyContact,
  });

  final int id;
  final int propertyId;
  final String fullName;
  final String phone;
  final String? email;
  final String? nationalId;
  final String? emergencyContact;

  /// Deactivated tenants keep their history and are never deleted.
  final bool isActive;

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
    id: json['id'] as int,
    propertyId: json['property_id'] as int,
    fullName: json['full_name'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String?,
    nationalId: json['national_id'] as String?,
    emergencyContact: json['emergency_contact'] as String?,
    isActive: json['is_active'] as bool,
  );
}
