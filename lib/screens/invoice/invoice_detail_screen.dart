import 'package:flutter/material.dart';
import 'package:kontor/services/invoice_service.dart';
import 'package:intl/intl.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/utils/constant.dart';
import 'package:kontor/widgets/custom_button.dart';
import 'package:kontor/widgets/custom_dialog.dart';
import 'package:kontor/widgets/custom_text.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final bool paid;
  final String invoiceId;
  const InvoiceDetailScreen(
      {required this.paid, required this.invoiceId, Key? key})
      : super(key: key);

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  Map<String, dynamic>? invoiceData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInvoiceDetails();
  }

  Future<void> _fetchInvoiceDetails() async {
    try {
      final response = await InvoiceService.getInvoiceDetail(widget.invoiceId);
      if (response['status']) {
        setState(() {
          invoiceData = response['data'];
        });
      }
    } catch (e) {
      print("Error fetching invoice details: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const CustomText(
          text: "Төлбөрийн задаргаа",
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
      bottomNavigationBar: widget.paid
          ? const SizedBox()
          : Container(
              margin: const EdgeInsets.only(bottom: 35, left: 65, right: 65),
              child: CustomButton(
                onPressed: () => {
                  showDialog(
                    context: context,
                    builder: (_) => EbarimtDialog(
                      invoiceIds: [widget.invoiceId], // pass your actual list
                      onClose: () => Navigator.pop(context),
                    ),
                  )
                },
                text: "Төлөх",
              ),
            ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : invoiceData == null
              ? const Center(child: Text("Алдаа гарлаа."))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Invoice summary card
                    _buildSummaryCard(),

                    // Details list
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: CustomText(
                        text: "Дэлгэрэнгүй",
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                  16, 0, 16, widget.paid ? 32 : 110),
                              child: Column(
                                children: [
                                  for (int i = 0;
                                      i < invoiceData!['details'].length;
                                      i++)
                                    InvoiceItemCard(
                                        item: invoiceData!['details'][i])
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text:
                "Нэхэмжлэл: ${invoiceData!['year']}-${invoiceData!['month']} сар",
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow("Нийт төлбөр:", invoiceData!['amount_total']),
          _buildSummaryRow("НӨАТ:", invoiceData!['amount_tax']),
          _buildSummaryRow("Үндсэн төлбөр:", invoiceData!['amount_untaxed']),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: label,
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
          CustomText(
            text: Constant.formatAmount(value),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}

class InvoiceItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const InvoiceItemCard({Key? key, required this.item}) : super(key: key);

  String formatAmount(num amount) {
    return NumberFormat("#,##0.00", "en_US").format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: item['name'],
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: "Хэмжээ: ${item['usage']}",
                fontSize: 13,
              ),
              CustomText(
                text: "Нэгж үнэ: ${formatAmount(item['price'])}₮",
                fontSize: 13,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: "Дүн: ${formatAmount(item['amount'])}₮",
                fontSize: 13,
              ),
              CustomText(
                text: "НӨАТ: ${formatAmount(item['noat'])}₮",
                fontSize: 13,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                text: "Нийт төлөх:",
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              CustomText(
                text: "${formatAmount(item['total_amount'])}₮",
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
