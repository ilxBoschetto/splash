// lib/widgets/minimal_notification.dart

import 'package:flutter/material.dart';

class MinimalNotification extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const MinimalNotification({
    Key? key,
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}

// lib/widgets/minimal_notification.dart (nello stesso file)

void showMinimalNotification(
  BuildContext context, {
  required String message,
  String position = 'bottom',
  int duration = 2000,
  Color? backgroundColor,
  Color? textColor,
  double fontSize = 14.0,
}) {
  final overlay = Overlay.of(context);
  final theme = Theme.of(context);

  final entry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: position == 'top' ? null : 40,
      top: position == 'top' ? 40 : null,
      left: 20,
      right: 20,
      child: MinimalNotification(
        message: message,
        backgroundColor:
            backgroundColor ?? theme.colorScheme.surfaceVariant,
        textColor: textColor ?? theme.colorScheme.onSurface,
        fontSize: fontSize,
      ),
    ),
  );

  overlay.insert(entry);

  Future.delayed(Duration(milliseconds: duration), () {
    entry.remove();
  });
}