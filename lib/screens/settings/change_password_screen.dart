import 'package:flutter/material.dart';
import 'package:kontor/services/auth_service.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/utils/resizer/fetch_pixels.dart';
import 'package:kontor/widgets/custom_button.dart';
import 'package:kontor/widgets/custom_snackbar.dart';
import 'package:kontor/widgets/custom_text.dart';
import 'package:kontor/widgets/custom_text_field.dart';
import 'package:kontor/widgets/loading_overlay.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool isLoading = false;

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  void _changePassword() async {
    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final repeatPass = _repeatPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || repeatPass.isEmpty) return;

    if (newPass != repeatPass) {
      showSnackBar(context, "Шинэ нууц үг зөрж байна", success: false);
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthService.changePassword(oldPass, newPass);

      if (!mounted) return;
      showSnackBar(context, "Нууц үг амжилттай солигдлоо", success: true);
      Navigator.pop(context);
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
              icon: const Icon(Icons.chevron_left, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
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
                const CustomText(
                  textAlign: TextAlign.center,
                  text:
                      'Та өөрийн хуучин болон шинэ нууц үгийг оруулан солино уу?',
                  paddingHorizontal: 16,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _oldPasswordController,
                  label: 'Хуучин нууц үг',
                  hintText: '••••••••',
                  isPassword: true,
                ),
                CustomTextField(
                  controller: _newPasswordController,
                  label: 'Шинэ нууц үг',
                  hintText: '••••••••',
                  isPassword: true,
                ),
                CustomTextField(
                  controller: _repeatPasswordController,
                  label: 'Нууц үг давтах',
                  hintText: '••••••••',
                  isPassword: true,
                ),
                CustomButton(
                  watchControllers: [
                    _oldPasswordController,
                    _newPasswordController,
                    _repeatPasswordController
                  ],
                  text: 'Үргэлжлүүлэх',
                  onPressed: _changePassword,
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
