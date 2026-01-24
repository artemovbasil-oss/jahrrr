import 'package:flutter/material.dart';

import '../models/client.dart';

const List<Color> kClientColorPalette = [
  Color(0xFF2D6EF8),
  Color(0xFF1FA85B),
  Color(0xFFB8432D),
  Color(0xFF6F3CC3),
  Color(0xFF16A3B7),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFF14B8A6),
  Color(0xFF8B5CF6),
  Color(0xFF0EA5E9),
];

String defaultClientColorHex() => colorToHex(kClientColorPalette.first);

String normalizeClientColorHex(String? hex) {
  final cleaned = hex?.replaceAll('#', '').trim() ?? '';
  if (cleaned.isEmpty) {
    return defaultClientColorHex();
  }
  final normalized = cleaned.toUpperCase();
  return '#$normalized';
}

Color resolveClientColor(Client client) {
  return colorFromHex(normalizeClientColorHex(client.avatarColorHex));
}

Color colorFromHex(String hex) {
  final cleaned = hex.replaceAll('#', '').trim();
  if (cleaned.isEmpty) {
    return kClientColorPalette.first;
  }
  final value = int.parse(cleaned, radix: 16);
  return Color(0xFF000000 | value);
}

String colorToHex(Color color) {
  final raw = color.value.toRadixString(16).padLeft(8, '0');
  return '#${raw.substring(2).toUpperCase()}';
}
