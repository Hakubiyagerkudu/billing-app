import 'package:flutter/material.dart';
import 'package:kontor/routes/app_routes.dart';
import 'package:kontor/services/auth_service.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/utils/resizer/fetch_pixels.dart';
import 'package:kontor/widgets/custom_button.dart';
import 'package:kontor/widgets/custom_snackbar.dart';
import 'package:kontor/widgets/custom_text.dart';
import 'package:kontor/widgets/custom_text_field.dart';
import 'package:kontor/widgets/loading_overlay.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool isLoading = false;
  final TextEditingController _userCodeController = TextEditingController();

  void _forgotPassword() async {
    final email = _userCodeController.text.trim();
    if (email.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final exists = await AuthService.checkUserRegistered(email);

      if (!mounted) return;

      if (exists) {
        Navigator.pushNamed(
          context,
          AppRoutes.verifyPassword,
          arguments: email,
        );
      }
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
                  text: 'Нууц үг мартсан?',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 12),
                const CustomText(
                  textAlign: TextAlign.center,
                  text:
                      'Системд бүртгэлтэй хэрэглэгчийн кодыг оруулж, өөрийн нэвтрэх нууц үгийг сэргээнэ үү.',
                  paddingHorizontal: 16,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _userCodeController,
                  label: 'Хэрэглэгчийн код',
                  hintText: '12345678',
                ),
                CustomButton(
                  watchControllers: [_userCodeController],
                  text: 'Үргэлжлүүлэх',
                  onPressed: _forgotPassword,
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
