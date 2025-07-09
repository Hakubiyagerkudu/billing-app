import 'package:flutter/material.dart';
import 'package:kontor/screens/home/home_chart.dart';
import 'package:kontor/widgets/custom_carousel.dart';
import 'package:kontor/screens/home/home_dashboard.dart';
import 'package:kontor/services/home_service.dart';
import 'package:kontor/utils/pref_data.dart';
import 'package:kontor/widgets/loading_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  String address = "";
  List<dynamic> invoiceMonthlyData = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    setState(() => isLoading = true);

    var userData = await PrefData.getUserData();
    setState(() => address = userData["address"]);

    _getInvoiceMonthly();
  }

  Future<void> _getInvoiceMonthly() async {
    final data = await HomeService.getInvoiceMonthlyData();
    if (data["status"]) {
      setState(() {
        invoiceMonthlyData = data["data"];
      });
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLoading ? 0 : 140),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeDashboard(address: address),
                        const CustomCarousel(),
                        const SizedBox(height: 16),
                        HomeLineChart(invoiceMonthlyData: invoiceMonthlyData),
                      ],
                    ),
                    if (isLoading) const LoadingOverlay()
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
