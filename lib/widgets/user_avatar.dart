import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    required this.email,
    this.size = 40,
  });

  final String? name;
  final String? email;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name, email);
    final color = _avatarColor(initials, email);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  String _initials(String? fullName, String? emailAddress) {
    final trimmed = fullName?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      final parts = trimmed.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
      final letters = parts.map((part) => part[0].toUpperCase()).toList();
      if (letters.length >= 2) {
        return letters.take(2).join();
      }
      if (letters.isNotEmpty) {
        return letters.first;
      }
    }
    final emailTrimmed = emailAddress?.trim() ?? '';
    if (emailTrimmed.isNotEmpty) {
      return emailTrimmed.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  Color _avatarColor(String initials, String? emailAddress) {
    final palette = <Color>[
      const Color(0xFF7C3AED),
      const Color(0xFF0F766E),
      const Color(0xFF0369A1),
      const Color(0xFFB45309),
      const Color(0xFFBE185D),
      const Color(0xFF2563EB),
      const Color(0xFF4D7C0F),
      const Color(0xFFB91C1C),
    ];
    final seed = '${initials.toLowerCase()}-${emailAddress?.toLowerCase() ?? ''}';
    var hash = 0;
    for (final rune in seed.runes) {
      hash = (hash + rune) % palette.length;
    }
    return palette[hash];
  }
}
