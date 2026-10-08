class Lease {
  const Lease({
    required this.id,
    required this.propertyId,
    required this.unitId,
    required this.unitLabel,
    required this.tenantId,
    required this.tenantName,
    required this.startDate,
    required this.endDate,
    required this.monthlyRent,
    required this.isActive,
    this.terminatedAt,
  });

  final int id;
  final int propertyId;

  /// Joined in by the API so a row renders without extra round trips.
  final int unitId;
  final String unitLabel;
  final int tenantId;
  final String tenantName;

  final DateTime startDate;
  final DateTime endDate;

  /// Whole XAF, locked at signing: there is no edit, only a new lease.
  final int monthlyRent;

  /// False once terminated. A terminated lease is history: it is excluded from
  /// the default list but still readable.
  final bool isActive;
  final DateTime? terminatedAt;

  bool get isExpired => endDate.isBefore(DateTime.now());

  /// True when the lease ends within [days] and has not ended yet.
  bool expiresWithin(int days) {
    if (!isActive || isExpired) return false;
    return endDate.difference(DateTime.now()).inDays <= days;
  }

  factory Lease.fromJson(Map<String, dynamic> json) {
    final terminatedAt = json['terminated_at'] as String?;
    return Lease(
      id: json['id'] as int,
      propertyId: json['property_id'] as int,
      unitId: json['unit_id'] as int,
      unitLabel: json['unit_label'] as String,
      tenantId: json['tenant_id'] as int,
      tenantName: json['tenant_name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      monthlyRent: (json['monthly_rent'] as num).toInt(),
      isActive: json['is_active'] as bool,
      terminatedAt: terminatedAt == null ? null : DateTime.parse(terminatedAt),
    );
  }
}
