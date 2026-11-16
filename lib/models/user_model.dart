// lib/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int points;
  final String memberTier; // Bronze, Silver, Gold

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.points = 100,
    this.memberTier = 'Gold Member',
  });
}

