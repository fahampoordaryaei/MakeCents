import 'package:flutter/material.dart';

Widget busyButton({
  required bool busy,
  required String label,
  TextStyle? labelStyle,
  double size = 22,
  Color indicatorColor = Colors.white,
}) {
  final style = labelStyle;
  if (busy) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: 2, color: indicatorColor),
    );
  }
  return Text(label, style: style);
}

ButtonStyle busyDialog() => FilledButton.styleFrom(
  backgroundColor: Color(0xFF3e7f3f),
  foregroundColor: Colors.white,
  minimumSize: const Size(100, 48),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
);

ButtonStyle busySave() => FilledButton.styleFrom(
  backgroundColor: Color(0xFF3e7f3f),
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
);
