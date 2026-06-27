class UserModel {
  final String id;
  final String username;
  final List<String> ownedRoles;
  final String activeRole;

  UserModel({
    required this.id,
    required this.username,
    required this.ownedRoles,
    required this.activeRole,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      // Supabase mengembalikan array PostgreSQL sebagai List<dynamic>
      ownedRoles: List<String>.from(json['owned_roles'] ?? []),
      activeRole: json['active_role'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'owned_roles': ownedRoles,
      'active_role': activeRole,
    };
  }

  // Tambahkan fungsi copyWith untuk memperbarui properti final secara aman
  UserModel copyWith({
    String? id,
    String? username,
    List<String>? ownedRoles,
    String? activeRole,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      ownedRoles: ownedRoles ?? this.ownedRoles,
      activeRole: activeRole ?? this.activeRole,
    );
  }
}