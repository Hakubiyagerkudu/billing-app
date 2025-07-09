import 'package:flutter/material.dart';
import 'package:kontor/screens/auth/login_screen.dart';
import 'package:kontor/screens/auth/register_screen.dart';
import 'package:kontor/screens/main_home.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/utils/endpoints.dart';
import 'package:kontor/utils/pref_data.dart';
import 'package:http/http.dart' as http;

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checking = true;
  dynamic _isAuthenticated = false;
  String rememberedUserCode = "";

  @override
  void initState() {
    super.initState();
    _loadRememberedUser();
  }

  Future<void> _loadRememberedUser() async {
    final savedUserCode = await PrefData.getRememberedUserCode();
    setState(() {
      rememberedUserCode = savedUserCode;
    });
    await _checkAccessToken();
  }

  Future<void> _checkAccessToken() async {
    print("🔍 Token check running...");

    final token = await PrefData.getAccessToken();

    if (token.isEmpty) {
      setState(() {
        _isAuthenticated = false;
        _checking = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(Endpoints.checkLogin),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        var userData = await PrefData.getUserData();
        if (userData["verified"]) {
          print("✅ Authenticated");
          setState(() {
            _isAuthenticated = true;
            _checking = false;
          });
        } else {
          print("❌ Not verified");
          setState(() {
            _isAuthenticated = null;
            _checking = false;
          });
        }
      } else {
        print("❌ Invalid token");
        setState(() {
          _isAuthenticated = false;
          _checking = false;
        });
      }
    } catch (e) {
      print("🔥 Error during token check: $e");
      setState(() {
        _isAuthenticated = false;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    if (_isAuthenticated == true) {
      return const MainHome();
    } else if (_isAuthenticated == null) {
      // If not verified, redirect to RegisterScreen
      return const RegisterScreen(); // 👈 Make sure this import exists
    } else {
      return LoginScreen(rememberedUserCode: rememberedUserCode);
    }
  }
}
