class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.updatedAt,
  });

  final String name;
  final String email;
  final DateTime updatedAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get displayName {
    if (name.trim().isNotEmpty) {
      return name.trim();
    }
    if (email.trim().isNotEmpty) {
      return email.trim();
    }
    return 'Friend';
  }

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      if (email.trim().isEmpty) {
        return 'U';
      }
      return email.trim().substring(0, 1).toUpperCase();
    }
    final parts = trimmed.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    final letters = parts.map((part) => part[0].toUpperCase()).toList();
    if (letters.isEmpty) {
      return 'U';
    }
    if (letters.length == 1) {
      return letters.first;
    }
    return letters.take(2).join();
  }
}
