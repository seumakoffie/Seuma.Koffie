// lib/models/user_model.dart

enum UserRole {
  customer,
  shift,
  admin;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'shift':
        return UserRole.shift;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }

  String get dbValue {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.shift:
        return 'shift';
      case UserRole.customer:
        return 'customer';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.shift:
        return 'Penjaga Shift';
      case UserRole.customer:
        return 'Konsumen';
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final int points;
  final String memberTier;
  final String? avatarUrl;
  final bool isActive;
  final String? phoneEncrypted;
  final String? encryptionIv;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = UserRole.customer,
    this.points = 100,
    this.memberTier = 'New Member',
    this.avatarUrl,
    this.isActive = true,
    this.phoneEncrypted,
    this.encryptionIv,
    this.createdAt,
  });

  static const Set<String> superAdminEmails = {
    'zarqud@gmail.com',
    'seumakoffie20@gmail.com',
  };

  static bool isSuperAdminEmail(String? email) {
    if (email == null) return false;
    return superAdminEmails.contains(email.toLowerCase().trim());
  }

  bool get isAdmin => role == UserRole.admin || isSuperAdminEmail(email);
  bool get isShift => role == UserRole.shift;
  bool get isCustomer => !isAdmin && !isShift;
  bool get hasStaffAccess => isAdmin || isShift;

  UserRole get effectiveRole => isAdmin ? UserRole.admin : role;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    int? points,
    String? memberTier,
    String? avatarUrl,
    bool? isActive,
    String? phoneEncrypted,
    String? encryptionIv,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      points: points ?? this.points,
      memberTier: memberTier ?? this.memberTier,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      phoneEncrypted: phoneEncrypted ?? this.phoneEncrypted,
      encryptionIv: encryptionIv ?? this.encryptionIv,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.dbValue,
      'points': points,
      'member_tier': memberTier,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'phone_encrypted': phoneEncrypted,
      'encryption_iv': encryptionIv,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Pengguna Seuma',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: UserRole.fromString(json['role']?.toString()),
      points: (json['points'] as num?)?.toInt() ?? 100,
      memberTier: json['member_tier']?.toString() ?? 'New Member',
      avatarUrl: json['avatar_url']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == null,
      phoneEncrypted: json['phone_encrypted']?.toString(),
      encryptionIv: json['encryption_iv']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}
