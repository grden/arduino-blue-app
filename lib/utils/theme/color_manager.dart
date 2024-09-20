import 'package:flutter/material.dart';

class ColorManager {
  static Color background = HexColor.fromHex("#1A2320");
  static Color white = HexColor.fromHex("#FFFEFF");
  static Color grey = HexColor.fromHex("#fbfcfc");
  static Color button = HexColor.fromHex("#32423E");
  static Color highlight = HexColor.fromHex("#a2b8b1");
  static Color error = HexColor.fromHex("#FF0A0A");
}

extension HexColor on Color {
  static Color fromHex(String hexColorString) {
    hexColorString = hexColorString.replaceAll('#', '');

    if (hexColorString.length == 6) {
      hexColorString = "FF$hexColorString";
    }

    return Color(int.parse(hexColorString, radix: 16));
  }
}
