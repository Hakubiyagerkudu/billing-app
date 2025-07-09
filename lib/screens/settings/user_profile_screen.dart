import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kontor/services/auth_service.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/utils/pref_data.dart';
import 'package:kontor/utils/resizer/fetch_pixels.dart';
import 'package:kontor/widgets/custom_button.dart';
import 'package:kontor/widgets/custom_snackbar.dart';
import 'package:kontor/widgets/custom_text.dart';
import 'package:kontor/widgets/custom_text_field.dart';
import 'package:kontor/widgets/loading_overlay.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isLoading = false;
  Map<String, dynamic> userData = {};

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ebarimtCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    var userData = await PrefData.getUserData();
    setState(() {
      _firstNameController.text = userData["first_name"];
      _lastNameController.text = userData["last_name"];
      _emailController.text = userData["email"];
      _phoneController.text = userData["phone"];
      _ebarimtCodeController.text = userData["ebarimt_customer_no"];
    });
  }

  void _updateUser() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final ebarimtNo = _ebarimtCodeController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty) {
      return;
    }

    // 📧 Email validation
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(email)) {
      showSnackBar(context, "Зөв имэйл хаяг оруулна уу", success: false);
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthService.editProfile(
          firstName, lastName, email, phone, ebarimtNo);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, "Оролдлого амжилтгүй", success: false);
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
                  text: 'Хэрэглэгчийн мэдээлэл',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 12),
                const CustomText(
                  textAlign: TextAlign.center,
                  text:
                      'Төлбөрийн И-баримтыг иргэний кодоо оруулан шууд авах боломжтой. Иргэний код нь таны И-Баримт апп-д нэвтрэхэд ашигладаг нэр юм.',
                  paddingHorizontal: 16,
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
                  controller: _ebarimtCodeController,
                  label: 'И-Баримт иргэний код',
                  hintText: '12345678',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                ),
                CustomButton(
                  watchControllers: [
                    _firstNameController,
                    _lastNameController,
                    _emailController,
                    _phoneController,
                  ],
                  paddingVertical: 16,
                  paddingHorizontal: 16,
                  text: 'Хадгалах',
                  onPressed: _updateUser,
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
