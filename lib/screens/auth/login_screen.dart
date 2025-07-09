import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kontor/routes/app_routes.dart';
import 'package:kontor/services/auth_service.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/utils/pref_data.dart';
import 'package:kontor/utils/resizer/fetch_pixels.dart';
import 'package:kontor/utils/widget_utils.dart';
import 'package:kontor/widgets/custom_button.dart';
import 'package:kontor/widgets/custom_checkbox.dart';
import 'package:kontor/widgets/custom_snackbar.dart';
import 'package:kontor/widgets/custom_text.dart';
import 'package:kontor/widgets/custom_text_field.dart';
import 'package:kontor/widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  final String rememberedUserCode;
  const LoginScreen({required this.rememberedUserCode, Key? key})
      : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  bool isRememberMe = false;
  final TextEditingController _userCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.rememberedUserCode.isNotEmpty) {
      setState(() {
        isRememberMe = true;
        _userCodeController.text = widget.rememberedUserCode;
      });
    }
  }

  Future<void> _rememberUserCode(bool remember) async {
    final userCode = _userCodeController.text.trim();
    setState(() => isRememberMe = remember);
    await PrefData.setRememberedUserCode(remember ? userCode : '');
  }

  void _login() async {
    final userCode = _userCodeController.text.trim();
    final password = _passwordController.text.trim();

    if (userCode.isEmpty || password.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final registered = await AuthService.login(userCode, password);

      if (!mounted) return;

      // Only one place to handle storing
      await _rememberUserCode(isRememberMe);

      if (registered) {
        Navigator.pushNamed(context, AppRoutes.home);
      } else {
        Navigator.pushNamed(
            context, AppRoutes.register); // Navigate to register screen
      }
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, e.toString(), success: false);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getAssetImage("logo_full.png", width: 180, height: 72),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _userCodeController,
                    label: 'Хэрэглэгчийн код',
                    hintText: '12345678',
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Нууц үг',
                    hintText: '••••••••',
                    isPassword: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: CustomCheckbox(
                      value: isRememberMe,
                      onChanged: (newValue) {
                        // Do something with newValue
                        _rememberUserCode(newValue ?? false);
                      },
                      label: "Намайг сана",
                    ),
                  ),
                  CustomButton(
                    watchControllers: [
                      _userCodeController,
                      _passwordController
                    ],
                    text: 'Нэвтрэх',
                    isLoading: isLoading,
                    onPressed: _login,
                    paddingVertical: 16,
                    paddingHorizontal: 16,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.forgotPassword),
                    child: CustomText(
                      text: "Нууц үг мартсан?",
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading) const LoadingOverlay()
          ],
        ),
      ),
    );
  }
}
