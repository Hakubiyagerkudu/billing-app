import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kontor/routes/app_routes.dart';
import 'package:kontor/services/auth_service.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/utils/resizer/fetch_pixels.dart';
import 'package:kontor/widgets/custom_button.dart';
import 'package:kontor/widgets/custom_snackbar.dart';
import 'package:kontor/widgets/custom_text_field.dart';
import 'package:kontor/widgets/loading_overlay.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isLoading = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _register() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await AuthService.register(
          firstName, lastName, email, phone, password);

      if (!mounted) return;

      if (success) {
        Navigator.pushNamed(context, AppRoutes.home);
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

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.black87),
                  onPressed: () async {
                    await AuthService.logout();
                    Navigator.pop(context);
                  }),
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
                  const Text(
                    'Шаардлагатай мэдээлэл',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          horizontalTitleGap: 0,
                          leading: Text('1.', style: TextStyle(fontSize: 14)),
                          title: Text(
                            'Та овог, нэр, имэйл хаяг болон утасны дугаараа оруулна уу.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          horizontalTitleGap: 0,
                          leading: Text('2.', style: TextStyle(fontSize: 14)),
                          title: Text(
                            'Төлбөрийн и-баримт болон нууц үг сэргээхэд шаардлагатай мэдээллийг системээс таны имэйл хаягаар илгээх тул үнэн зөв оруулна уу.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          horizontalTitleGap: 0,
                          leading: Text('3.', style: TextStyle(fontSize: 14)),
                          title: Text(
                            'Шинэ нууц үг оруулан, нэг удаагийн нэвтрэх нууц үгийг солино уу.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _lastNameController,
                    label: 'Овог',
                    hintText: 'Бат',
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  CustomTextField(
                    controller: _firstNameController,
                    label: 'Нэр',
                    hintText: 'Амар',
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Утасны дугаар',
                    hintText: '8888****',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Имэйл хаяг',
                    hintText: 'user@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Нууц үг',
                    hintText: '••••••••',
                    isPassword: true,
                  ),
                  CustomButton(
                    watchControllers: [
                      _firstNameController,
                      _lastNameController,
                      _emailController,
                      _phoneController,
                      _passwordController
                    ],
                    text: 'Үргэлжлүүлэх',
                    onPressed: _register,
                    paddingVertical: 16,
                    paddingHorizontal: 16,
                  ),
                ],
              ),
            ),
          ),
          if (isLoading) const LoadingOverlay()
        ],
      ),
    );
  }
}
