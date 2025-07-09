import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/widgets/custom_text.dart';

class HomeLineChart extends StatefulWidget {
  final List<dynamic> invoiceMonthlyData;
  const HomeLineChart({required this.invoiceMonthlyData, Key? key})
      : super(key: key);

  @override
  State<HomeLineChart> createState() => _HomeLineChartState();
}

class _HomeLineChartState extends State<HomeLineChart> {
  final now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    List<String> months = List.generate(12, (i) => "${i + 1}-р сар");

    // Variables are used only invoiceMonthlyData is empty
    const int roundedMaxEmpty = 50;
    const int stepEmpty = 10;

    final Map<int, String> leftTitleEmpty = {
      for (int i = 0; i <= roundedMaxEmpty; i += stepEmpty) i: '${i}K',
    };

    final dataSpotsEmpty = List.generate(
      12,
      (index) => FlSpot(index.toDouble(), double.nan),
    );

    // Convert invoiceMonthlyData to a list of amounts in thousands (1000₮)
    final rawData = widget.invoiceMonthlyData.map<double>((element) {
      final raw = element["amount_total"];
      if (raw == null) return 0;
      return (raw is num
              ? raw.toDouble()
              : double.tryParse(raw.toString()) ?? 0) /
          1000;
    }).toList();

    // Check if there's any meaningful (non-zero) data
    final bool hasData = rawData.any((v) => v > 0);
    final double maxK =
        rawData.isNotEmpty ? rawData.reduce((a, b) => a > b ? a : b) : 0;

    // Dynamically calculate Y-axis step based on max value
    int getStep(double max) {
      if (max <= 100) return 10;
      if (max <= 300) return 50;
      if (max <= 1000) return 100;
      if (max <= 2000) return 200;
      return 500;
    }

    // Final step size for Y-axis labels (e.g., 0, 50, 100, ..., maxK)
    final step = getStep(maxK);
    final roundedMax = ((maxK / step).ceil()) * step;

    // Generate Y-axis labels like {0: '0K', 50: '50K', ...}
    final Map<int, String> leftTitle = {
      for (int i = 0; i <= roundedMax; i += step) i: '${i}K',
    };

    // Map rawData to FlSpot list for plotting (x = month index, y = value)
    final dataSpots = rawData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();

    return Container(
      // height: MediaQuery.of(context).size.height * 0.4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: "Төлбөрийн мэдээлэл сараар",
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 4),
          CustomText(
            text:
                "Энэхүү графикт ${now.month == 1 ? now.year - 1 : now.year} он төлбөл зохих төлбөрийн дүнг сараар харуулав",
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 3 / 2,
            child: Stack(
              alignment: Alignment.center,
              children: [
                LineChart(
                  swapAnimationDuration: Duration.zero,
                  LineChartData(
                    minX: 0,
                    maxX: 11,
                    minY: 0,
                    maxY: hasData
                        ? roundedMax.toDouble()
                        : roundedMaxEmpty.toDouble(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval:
                              hasData ? step.toDouble() : stepEmpty.toDouble(),
                          getTitlesWidget: (value, meta) {
                            final titles = hasData ? leftTitle : leftTitleEmpty;
                            return titles[value.toInt()] != null
                                ? Text(titles[value.toInt()]!,
                                    style: const TextStyle(fontSize: 12))
                                : const SizedBox();
                          },
                        ),
                      ),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value < 0 || value >= months.length) {
                              return const SizedBox.shrink();
                            }
                            return Transform.translate(
                              offset: const Offset(5, 5),
                              child: Transform.rotate(
                                angle: -80 * 3.1416 / 180,
                                child: Text(
                                  months[value.toInt()],
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Colors.white,
                        tooltipRoundedRadius: 12,
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((LineBarSpot touchedSpot) {
                            final index = touchedSpot.x.toInt();
                            final amount =
                                (index < widget.invoiceMonthlyData.length)
                                    ? widget.invoiceMonthlyData[index]
                                            ["amount_total"] ??
                                        0
                                    : 0;

                            return LineTooltipItem(
                              '${NumberFormat("#,##0.00", "en_US").format(amount)}₮',
                              const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: hasData ? dataSpots : dataSpotsEmpty,
                        isCurved: true,
                        color: primaryColor,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: primaryColor.withOpacity(0.1),
                        ),
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
                if (!hasData)
                  const CustomText(
                    text: "Өгөгдөл олдсонгүй",
                    fontSize: 14,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
