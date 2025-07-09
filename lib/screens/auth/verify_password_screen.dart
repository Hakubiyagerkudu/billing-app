import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kontor/routes/app_routes.dart';
import 'package:kontor/services/auth_service.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/utils/resizer/fetch_pixels.dart';
import 'package:kontor/widgets/custom_button.dart';
import 'package:kontor/widgets/custom_snackbar.dart';
import 'package:kontor/widgets/custom_text.dart';
import 'package:kontor/widgets/custom_text_field.dart';
import 'package:kontor/widgets/loading_overlay.dart';

class VerifyPasswordScreen extends StatefulWidget {
  final String email;
  const VerifyPasswordScreen({required this.email, Key? key}) : super(key: key);

  @override
  State<VerifyPasswordScreen> createState() => _VerifyPasswordScreenState();
}

class _VerifyPasswordScreenState extends State<VerifyPasswordScreen> {
  bool isLoading = false;

  final TextEditingController _verifyCodeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _repeatedPasswordController =
      TextEditingController();

  void _verifyPassword() async {
    final verifyCode = _verifyCodeController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final repeatPass = _repeatedPasswordController.text.trim();

    if (verifyCode.isEmpty || newPass.isEmpty || repeatPass.isEmpty) return;

    if (newPass != repeatPass) {
      showSnackBar(context, "Шинэ нууц үг зөрж байна", success: false);
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthService.forgotPassword(verifyCode, newPass);

      if (!mounted) return;
      showSnackBar(context, "Нууц үг амжилттай солигдлоо", success: true);
      Navigator.pushNamed(context, AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, e.toString(), success: false);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: Colors.black87,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
            padding: EdgeInsets.only(
              left: 12.0,
              right: 12.0,
              bottom: MediaQuery.of(context).viewPadding.bottom + 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomText(
                  text: 'Нууц үг солих',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 12),
                CustomText(
                  textAlign: TextAlign.center,
                  text:
                      'Таны бүртгэлтэй ${widget.email} имэйл хаягт илгээгдсэн баталгаажуулах кодыг оруулж, нууц үгээ солино уу?',
                  paddingHorizontal: 16,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _verifyCodeController,
                  label: 'Баталгаажуулах код',
                  hintText: '123456',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                ),
                CustomTextField(
                  controller: _newPasswordController,
                  label: 'Шинэ нууц үг',
                  hintText: '••••••••',
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                ),
                CustomTextField(
                  controller: _repeatedPasswordController,
                  label: 'Нууц үг давтах',
                  hintText: '••••••••',
                  isPassword: true,
                ),
                CustomButton(
                  text: 'Үргэлжлүүлэх',
                  onPressed: _verifyPassword,
                  paddingVertical: 16,
                  paddingHorizontal: 16,
                ),
              ],
            ),
          ),
        ),
        if (isLoading) const LoadingOverlay()
      ],
    );
  }
}
