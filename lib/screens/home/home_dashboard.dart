import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kontor/services/home_service.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/utils/widget_utils.dart';
import 'package:kontor/widgets/custom_dialog.dart';
import 'package:kontor/widgets/custom_text.dart';

class HomeDashboard extends StatefulWidget {
  final String address;
  const HomeDashboard({required this.address, Key? key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(24), // 👈 clip everything to rounded shape
        child: Stack(
          children: [
            // 🟦 Background container with gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.center,
                  colors: [primaryColor, primaryDarkColor],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  top: 20,
                  bottom: 20,
                  right: screenWidth * 0.35, // responsive right padding
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      text: "Хаяг",
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      text: widget.address,
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      maxLines: 2,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                ),
                              );
                            },
                          );

                          try {
                            final result = await HomeService.getApartmentInfo();
                            if (!mounted) return;

                            Navigator.pop(context); // Close loading dialog

                            showDialog(
                              context: context,
                              builder: (_) => CustomDialog(
                                title: 'Дэлгэрэнгүй мэдээлэл',
                                buttonText: 'Хаах',
                                onPressed: () => Navigator.pop(context),
                                onClose: () => Navigator.pop(context),
                                child: buildPersonInfo(result["data"]),
                              ),
                            );
                          } catch (e) {
                            Navigator.pop(context); // Close loading dialog

                            showDialog(
                              context: context,
                              builder: (_) => CustomDialog(
                                title: 'Алдаа гарлаа',
                                buttonText: 'Хаах',
                                onPressed: () => Navigator.pop(context),
                                onClose: () => Navigator.pop(context),
                                child: Text(
                                  e is Map
                                      ? (e["error"] ?? "Алдаа")
                                      : "Алдаа гарлаа",
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text(
                          "Дэлгэрэнгүй",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🖼️ Image positioned INSIDE the clipped container
            Positioned(
              right: -10,
              bottom: 0,
              child: SizedBox(
                width: screenWidth * 0.5,
                child: getAssetImage("home_apartment.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildPersonInfo(Map<String, dynamic> data) {
  final apartment = data['apartment'] ?? {};
  final city = apartment['aimag']?['name'] ?? '';
  final duureg = apartment['duureg']?['name'] ?? '';
  final horoo = apartment['horoo']?['name'] ?? '';
  final companyName = apartment['company']?['name'] ?? '';
  final corps = apartment['corps'] ?? '';
  final address = data['address'] ?? '';
  final family = data['family']?.toString() ?? '';

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      InfoRow(label: 'ХҮТ:', value: companyName),
      InfoRow(label: 'Хот:', value: city),
      InfoRow(label: 'Дүүрэг:', value: duureg),
      InfoRow(label: 'Хороо:', value: horoo),
      InfoRow(label: 'Корпс:', value: corps),
      InfoRow(label: 'Тоот:', value: address),
      InfoRow(label: 'Ам бүлийн тоо:', value: family),
    ],
  );
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: CustomText(
              text: label,
              fontWeight: FontWeight.w400,
              fontSize: 15,
              textAlign: TextAlign.right,
            ),
          ),
          Flexible(
            flex: 2,
            child: CustomText(
              text: value,
              fontWeight: FontWeight.w400,
              fontSize: 15,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
