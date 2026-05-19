class User {
  const User({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.role,
    this.agencyId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        phone: json['phone'] as String? ?? '',
        name: json['name'] as String?,
        email: json['email'] as String?,
        role: json['role'] as String?,
        agencyId: json['agency_id'] as String?,
      );

  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String? role;
  final String? agencyId;

  bool get isAgencyOwner => role == 'agency_owner' && agencyId != null;
  bool get isAdmin => role == 'admin' || role == 'super_admin';
}
