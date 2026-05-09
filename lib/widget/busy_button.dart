import 'package:flutter/material.dart';

Widget busyButton({
  required BuildContext context,
  required bool busy,
  required String label,
  TextStyle? labelStyle,
  double size = 22,
  Color? indicatorColor,
}) {
  final scheme = Theme.of(context).colorScheme;
  final spinColor = indicatorColor ?? scheme.onPrimary;
  final style = labelStyle;
  if (busy) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: 2, color: spinColor),
    );
  }
  return Text(label, style: style);
}

ButtonStyle busyDialog(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return FilledButton.styleFrom(
    backgroundColor: scheme.primary,
    foregroundColor: scheme.onPrimary,
    minimumSize: const Size(100, 48),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}

ButtonStyle busySave(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return FilledButton.styleFrom(
    backgroundColor: scheme.primary,
    foregroundColor: scheme.onPrimary,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  );
}
