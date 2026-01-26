import 'package:flutter/material.dart';

Color contrastColorFor(
  Color background, {
  Color light = Colors.black,
  Color dark = Colors.white,
}) {
  final brightness = ThemeData.estimateBrightnessForColor(background);
  return brightness == Brightness.dark ? dark : light;
}
