class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String avatarInitials;
  double balance;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.balance,
  }) : avatarInitials = _getInitials(name);

  static String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}

// Mock contacts for transfers
class Contact {
  final String id;
  final String name;
  final String phone;
  final String initials;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
  }) : initials = _getInitials(name);

  static String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}

// Mock merchants for purchases
class Merchant {
  final String id;
  final String name;
  final String category;
  final String icon;

  const Merchant({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
  });
}