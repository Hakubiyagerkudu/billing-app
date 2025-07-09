import 'package:flutter/material.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/utils/resizer/fetch_pixels.dart';
import 'package:kontor/widgets/custom_text.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({Key? key}) : super(key: key);

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  @override
  Widget build(BuildContext context) {
    FetchPixels(context);

    return Scaffold(
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
        child: const Center(
          child: CustomText(
            text: 'Тоолуурын заалт оруулах',
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
