import 'package:flutter/material.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/widgets/custom_text.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final List<TextEditingController>? watchControllers;
  final Color? color;
  final Color? disabledColor;
  final bool isLoading;
  final double? width;
  final double? paddingHorizontal;
  final double? paddingVertical;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.watchControllers,
    this.color,
    this.width,
    this.disabledColor,
    this.paddingHorizontal,
    this.paddingVertical,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool enabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.watchControllers != null) {
      for (var c in widget.watchControllers!) {
        c.addListener(_checkControllers);
      }
      _checkControllers();
    }
  }

  @override
  void dispose() {
    widget.watchControllers?.forEach((c) {
      c.removeListener(_checkControllers);
    });
    super.dispose();
  }

  void _checkControllers() {
    final filled =
        widget.watchControllers!.every((c) => c.text.trim().isNotEmpty);

    if (filled != enabled) {
      setState(() {
        enabled = filled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isButtonEnabled = enabled && !widget.isLoading;

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: widget.paddingVertical ?? 0,
          horizontal: widget.paddingHorizontal ?? 0),
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isButtonEnabled ? widget.onPressed : null,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (!enabled) {
                  return widget.disabledColor ?? Colors.grey.shade300;
                }
                return widget.color ?? primaryColor;
              },
            ),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (!enabled) {
                  return subTextColor;
                }
                return Colors.white;
              },
            ),
            elevation: MaterialStateProperty.resolveWith<double>(
              (Set<MaterialState> states) {
                return !enabled ? 0 : 3;
              },
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            animationDuration: const Duration(milliseconds: 200),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 16.0),
            ),
          ),
          child: CustomText(
            text: widget.text,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
