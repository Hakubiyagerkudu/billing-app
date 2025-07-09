import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kontor/routes/app_routes.dart';
import 'package:kontor/services/invoice_service.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/utils/constant.dart';
import 'package:kontor/widgets/custom_snackbar.dart';
import 'package:kontor/widgets/custom_text.dart';
import 'package:kontor/widgets/loading_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  final List<dynamic> invoiceIds;
  final String userType;
  final String userRegister;

  const PaymentScreen({
    required this.invoiceIds,
    required this.userType,
    required this.userRegister,
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with WidgetsBindingObserver {
  bool isLoading = true;
  bool isFetching = false;
  Map<String, dynamic> qpayInvoiceData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer
    _getQpayInvoiceData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Clean up
    super.dispose();
  }

  Future<void> _getQpayInvoiceData() async {
    final data = await InvoiceService.getQpayInvoice(
      widget.invoiceIds,
      widget.userType,
      widget.userRegister,
    );
    if (data["status"] && data["data"] != null) {
      setState(() {
        qpayInvoiceData = data["data"];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      setState(() => isFetching = true);

      try {
        final paid = await InvoiceService.checkPayment(
            qpayInvoiceData["callback_url"] ?? "");

        if (paid && mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.home,
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        // Optional: showSnackBar(context, "Төлбөр шалгах үед алдаа гарлаа", success: false);
      } finally {
        if (mounted) setState(() => isFetching = false);
      }
    }
  }

  Future _launchURLApp(String appName, url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            centerTitle: true,
            title: const CustomText(
              text: "Төлбөр",
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : Column(
                    children: [
                      if (qpayInvoiceData.isNotEmpty)
                        PaymentDashboard(
                          amount: double.tryParse(
                                  qpayInvoiceData["amount"].toString()) ??
                              0.0,
                          qrImage: qpayInvoiceData["qr_image"],
                          checkPaymentURL: qpayInvoiceData["callback_url"],
                        ),
                      if (qpayInvoiceData['urls'] != null &&
                          qpayInvoiceData['urls'] is List)
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: qpayInvoiceData['urls'].length,
                            itemBuilder: (context, index) {
                              final item = qpayInvoiceData['urls'][index];
                              return GestureDetector(
                                onTap: () => _launchURLApp(
                                    item['description'] as String,
                                    item['link']),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.07),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          item['logo'],
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomText(
                                              text: item['description'] ?? '',
                                              fontSize: 15,
                                            ),
                                            const SizedBox(height: 4),
                                            CustomText(
                                              text: item['name'] ?? '',
                                              fontSize: 13,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
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
                            },
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        if (isFetching) const LoadingOverlay()
      ],
    );
  }
}

class PaymentDashboard extends StatelessWidget {
  final double amount;
  final String qrImage;
  final String checkPaymentURL;

  const PaymentDashboard({
    required this.amount,
    required this.qrImage,
    required this.checkPaymentURL,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageBytes = qrImage.isNotEmpty ? base64Decode(qrImage) : null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.center,
          colors: [primaryColor, primaryDarkColor],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: "Нийт дүн: ${Constant.formatAmount(amount)}",
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                const CustomText(
                  text: "Та төлбөрөө QR код уншуулж эсвэл банкаар төлнө үү.",
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    onPressed: () async {
                      final paid =
                          await InvoiceService.checkPayment(checkPaymentURL);
                      if (paid) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.home,
                          (Route<dynamic> route) => false,
                        );
                      } else {
                        showSnackBar(context, "Төлбөр төлөгдөөгүй байна",
                            success: false);
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
                      "Төлбөр шалгах",
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
          const SizedBox(width: 12),
          if (imageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                width: 110,
              ),
            ),
        ],
      ),
    );
  }
}
