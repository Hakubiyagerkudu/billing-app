import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:kontor/screens/auth/auth_gate.dart';
import 'package:kontor/utils/color_data.dart';
import 'routes/app_routes.dart';

void main() {
  // runApp(DevicePreview(enabled: true, builder: (context) => const MyApp()));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Osnaaug',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoutes.generateRoute,
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
          background: backgroundColor,
          surface: Colors.white,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
