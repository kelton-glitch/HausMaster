enum UnitStatus {
  vacant,
  occupied;

  static UnitStatus fromJson(String value) => UnitStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => vacant,
  );
}

class UnitType {
  const UnitType({
    required this.id,
    required this.propertyId,
    required this.name,
    required this.roomCount,
    required this.baseRent,
    required this.isActive,
  });

  final int id;
  final int propertyId;
  final String name;
  final int roomCount;

  /// Whole XAF (no minor unit).
  final int baseRent;
  final bool isActive;

  factory UnitType.fromJson(Map<String, dynamic> json) => UnitType(
    id: json['id'] as int,
    propertyId: json['property_id'] as int,
    name: json['name'] as String,
    roomCount: json['room_count'] as int,
    baseRent: (json['base_rent'] as num).toInt(),
    isActive: json['is_active'] as bool,
  );
}

class Unit {
  const Unit({
    required this.id,
    required this.propertyId,
    required this.label,
    required this.unitTypeId,
    required this.unitTypeName,
    required this.status,
  });

  final int id;
  final int propertyId;
  final String label;
  final int unitTypeId;
  final String unitTypeName;
  final UnitStatus status;

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
    id: json['id'] as int,
    propertyId: json['property_id'] as int,
    label: json['label'] as String,
    unitTypeId: json['unit_type_id'] as int,
    unitTypeName: json['unit_type_name'] as String,
    status: UnitStatus.fromJson(json['status'] as String),
  );
}
