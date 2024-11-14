import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';

void showToast(BuildContext context, String message, bool success) {
  final shadowColor = Theme.of(context).brightness == Brightness.dark
      ? const Color.fromARGB(14, 255, 255, 255)
      : null;

  DelightToastBar(
    position: DelightSnackbarPosition.top,
    autoDismiss: true,
    builder: (context) => ToastCard(
      shadowColor: shadowColor,
      leading: Icon(
        success ? Icons.check_circle : Icons.flutter_dash,
        size: 28,
      ),
      title: Text(
        message,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    ),
  ).show(context);
}
