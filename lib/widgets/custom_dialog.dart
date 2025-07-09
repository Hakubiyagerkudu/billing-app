import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kontor/routes/app_routes.dart';
import 'package:kontor/services/invoice_service.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/widgets/custom_button.dart';
import 'package:kontor/widgets/custom_snackbar.dart';
import 'package:kontor/widgets/custom_text.dart';
import 'package:kontor/widgets/custom_text_field.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onPressed;
  final VoidCallback? onClose;
  final Widget child;

  const CustomDialog({
    Key? key,
    required this.title,
    required this.buttonText,
    required this.onPressed,
    required this.child,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 12,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and optional close button
            Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: title,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (onClose != null)
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.black54,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Body content
            child,

            const SizedBox(height: 20),

            // Confirm button
            CustomButton(
              text: buttonText,
              onPressed: onPressed,
              width: double.infinity,
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }
}

class EbarimtDialog extends StatefulWidget {
  final List<dynamic> invoiceIds;
  final void Function()? onClose;

  const EbarimtDialog({
    required this.invoiceIds,
    this.onClose,
    Key? key,
  }) : super(key: key);

  @override
  State<EbarimtDialog> createState() => _EbarimtDialogState();
}

class _EbarimtDialogState extends State<EbarimtDialog> {
  String errorMsg = "";
  String _selectedType = 'OS';
  final TextEditingController _registerController = TextEditingController();

  void _onContinue() async {
    final userType = _selectedType;
    final register = _registerController.text;

    // Optional: validate register for AAN
    if (userType == 'AAN') {
      if (register.isEmpty) {
        setState(() => errorMsg = "Регистрийн дугаар оруулна уу");
        Timer(const Duration(seconds: 3), () {
          setState(() => errorMsg = "");
        });
        return;
      } else {
        final result = await InvoiceService.checkUserRegister(register);

        if (!result["status"]) {
          setState(() => errorMsg = result["error"]);
          Timer(const Duration(seconds: 3), () {
            setState(() => errorMsg = "");
          });
          return;
        }
      }
    }

    Navigator.pop(context); // Close dialog
    // Navigate to qpayInvoice screen with arguments
    Navigator.pushNamed(
      context,
      AppRoutes.qpayInvoice,
      arguments: {
        'invoiceIds': widget.invoiceIds,
        'userType': userType,
        'userRegister': register,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 12,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title + Close
            // Header with title and optional close button
            Row(
              children: [
                const Expanded(
                  child: CustomText(
                    text: "Төлбөрийн баримт",
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const CustomText(
              text:
                  'Та төлбөрийн баримт авах хэлбэрээ сонгон үргэлжлүүлэх товчийг дарна уу.',
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),

            const SizedBox(height: 16),

            // Type selection
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'OS',
                    groupValue: _selectedType,
                    activeColor: primaryColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: const Text("Хувь хүн"),
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                  const Divider(height: 0),
                  RadioListTile<String>(
                    value: 'AAN',
                    groupValue: _selectedType,
                    activeColor: primaryColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: const Text("Байгууллага"),
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                ],
              ),
            ),

            // Register input
            _selectedType == 'AAN'
                ? CustomTextField(
                    controller: _registerController,
                    label: 'Регистрийн дугаар',
                    paddingHorizontal: 0,
                    paddingVertical: 16,
                  )
                : const SizedBox(height: 16),

            if (errorMsg.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CustomSnackbar(
                  color: errorColor,
                  icon: Icons.error,
                  message: errorMsg,
                ),
              ),
            // Continue button
            CustomButton(
              watchControllers: const [],
              text: 'Үргэлжлүүлэх',
              onPressed: _onContinue,
            ),
          ],
        ),
      ),
    );
  }
}
