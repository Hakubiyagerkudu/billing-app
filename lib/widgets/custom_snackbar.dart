import 'package:flutter/material.dart';
import 'package:kontor/utils/color_data.dart';

void showSnackBar(BuildContext context, String message, {bool success = true}) {
  final color = success ? successColor : errorColor;
  final icon = success ? Icons.check_circle : Icons.error;

  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: CustomSnackbar(
      color: color,
      icon: icon,
      message: message,
    ),
    duration: const Duration(seconds: 3),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class CustomSnackbar extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String message;
  const CustomSnackbar(
      {required this.color,
      required this.icon,
      required this.message,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
