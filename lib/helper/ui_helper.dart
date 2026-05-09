import 'package:flutter/material.dart';

bool passwordCriteria(String pass) {
  return pass.length >= 8 &&
      RegExp(r'[A-Z]').hasMatch(pass) &&
      RegExp(r'[a-z]').hasMatch(pass) &&
      RegExp(r'[0-9]').hasMatch(pass) &&
      RegExp(r'[^a-zA-Z0-9\s]').hasMatch(pass);
}

Widget buildProductImage(
  String id, {
  required double size,
  required double radius,
  Color? fallbackColor,
  Widget? fallbackChild,
}) {
  final imageId = id.replaceAll('-', '');
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(
      'assets/products/$imageId.jpg',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: size,
        height: size,
        color: fallbackColor ?? Colors.grey.withValues(alpha: 0.2),
        child: fallbackChild,
      ),
    ),
  );
}

enum AppAlertLevel { warning, error, success }

Future<void> popupAlert(
  BuildContext context, {
  required String message,
  required AppAlertLevel level,
}) async {
  if (!context.mounted) return;

  final icon = level == AppAlertLevel.warning
      ? Icons.warning_amber_rounded
      : level == AppAlertLevel.error
      ? Icons.error_rounded
      : Icons.check_circle_rounded;

  final bg = level == AppAlertLevel.warning
      ? const Color(0xFFFFF3E0)
      : level == AppAlertLevel.error
      ? Theme.of(context).colorScheme.errorContainer
      : const Color(0xFFE8F5E9);

  final fg = level == AppAlertLevel.warning
      ? const Color(0xFFEF6C00)
      : level == AppAlertLevel.error
      ? Theme.of(context).colorScheme.onErrorContainer
      : const Color(0xFF2E7D32);

  var visible = true;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 20,
      right: 20,
      bottom: MediaQuery.of(context).padding.bottom + 90,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        onEnd: () {
          if (!visible) entry.remove();
        },
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: bg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: fg, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(entry);
  Future.delayed(const Duration(seconds: 3), () {
    visible = false;
    entry.markNeedsBuild();
  });
}

Widget scholarshipRegionLabel(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withValues(alpha: 0.35)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.place, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}
