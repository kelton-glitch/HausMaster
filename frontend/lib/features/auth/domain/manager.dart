class Manager {
  const Manager({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
  });

  final int id;
  final String fullName;
  final String email;
  final String? phone;

  factory Manager.fromJson(Map<String, dynamic> json) => Manager(
    id: json['id'] as int,
    fullName: json['full_name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String?,
  );
}
