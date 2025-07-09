import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color color;
  final int? maxLines;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final TextOverflow? textOverflow;
  final double? paddingHorizontal;

  const CustomText({
    Key? key,
    required this.text,
    this.color = Colors.black87,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.fontSize,
    this.textOverflow,
    this.paddingHorizontal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal ?? 0),
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: fontSize ?? fontSize,
          color: color,
          fontWeight: fontWeight,
          overflow: textOverflow,
        ),
      ),
    );
  }
}
