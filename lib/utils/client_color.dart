import 'dart:math';

import 'package:flutter/material.dart';

import '../models/client.dart';

const List<Color> kClientColorPalette = [
  Color(0xFF2D6EF8),
  Color(0xFF1FA85B),
  Color(0xFFB8432D),
  Color(0xFF8D9BA7),
  Color(0xFF6F3CC3),
  Color(0xFF16A3B7),
];

Color resolveClientColor(Client client) {
  if (client.avatarColorHex.isEmpty) {
    return kClientColorPalette.first;
  }
  return colorFromHex(client.avatarColorHex);
}

String generateClientColorHex(Random random) {
  final color = kClientColorPalette[random.nextInt(kClientColorPalette.length)];
  return colorToHex(color);
}

Color colorFromHex(String hex) {
  final cleaned = hex.replaceAll('#', '');
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
