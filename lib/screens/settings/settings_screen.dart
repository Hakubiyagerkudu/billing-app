import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:kontor/routes/app_routes.dart';
import 'package:kontor/services/auth_service.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/utils/pref_data.dart';
import 'package:kontor/widgets/custom_dialog.dart';
import 'package:kontor/widgets/custom_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileOptions = [
      {
        "title": "Хэрэглэгчийн мэдээлэл",
        "path": AppRoutes.userProfile,
      },
      {
        "title": "Нууц үг солих",
        "path": AppRoutes.changePassword,
      },
      {
        "title": "Тоолуурын заалт",
        "path": AppRoutes.counter,
      },
      {
        "title": "Апп-ын тохиргоо",
        "path": "",
      },
      {
        "title": "Бүртгэл устгах",
        "path": "",
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...profileOptions.map((option) {
                        return GestureDetector(
                          onTap: () async {
                            final title = option["title"];

                            if (title == "Апп-ын тохиргоо") {
                              AppSettings.openAppSettings();
                            } else if (title == "Бүртгэл устгах") {
                              try {
                                // Show confirmation dialog
                                showDialog(
                                  context: context,
                                  builder: (_) => CustomDialog(
                                    title: 'Бүртгэл устгах',
                                    buttonText: 'Тийм, устгах',
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                      // TODO: Add your delete account API logic here
                                      print("Account deleted.");
                                    },
                                    onClose: () => Navigator.pop(context),
                                    child: const CustomText(
                                      text:
                                          'Та бүртгэлээ бүрмөсөн устгахдаа итгэлтэй байна уу? Энэ үйлдлийг буцаах боломжгүй.',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                Navigator.pop(context); // In case of error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Алдаа гарлаа: $e")),
                                );
                              }
                            } else if (option["path"]!.isNotEmpty) {
                              Navigator.pushNamed(context, option["path"]!);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  text: option["title"]!,
                                  fontSize: 14,
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const Spacer(),
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            final savedUserCode =
                                await PrefData.getRememberedUserCode();

                            await AuthService.logout();

                            Navigator.pushNamed(context, AppRoutes.login,
                                arguments: savedUserCode);
                          },
                          child: Text(
                            "Гарах",
                            style: TextStyle(
                              color: errorColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
