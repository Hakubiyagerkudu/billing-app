import 'package:flutter/material.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/widgets/custom_text.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final bool shrink;
  final ValueChanged<bool?> onChanged;
  final String label;

  const CustomCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    this.label = '',
    this.shrink = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CheckboxTheme(
      data: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        side: const BorderSide(color: Colors.grey),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor,
            // Conditionally assign shrinkWrap or default
            materialTapTargetSize: shrink
                ? MaterialTapTargetSize.shrinkWrap
                : MaterialTapTargetSize.padded,
            visualDensity:
                shrink ? VisualDensity.compact : VisualDensity.standard,
          ),
          if (label.isNotEmpty)
            Transform.translate(
              offset: const Offset(-4, 0),
              child: GestureDetector(
                onTap: () => onChanged(!value),
                child: CustomText(text: label, color: subTextColor),
              ),
            ),
        ],
      ),
    );
  }
}
