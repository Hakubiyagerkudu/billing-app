import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kontor/utils/color_data.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent dark layer
        Container(
          color:
              Colors.black.withOpacity(0), // lighter opacity for transparency
        ),

        // Frosted glass blur effect
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black
                .withOpacity(0), // Needed for BackdropFilter to work
          ),
        ),

        // Center spinner
        Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      ],
    );
  }
}
