import 'dart:ui';

Color backgroundColor = "#FAFAFA".toColor();
Color primaryColor = "#078DEE".toColor();
Color primaryDarkColor = "#0351AB".toColor();
Color secondaryColor = "#FFA03F".toColor();
Color infoColor = "#00B8D9".toColor();
Color successColor = "#36B37E".toColor();
Color warningColor = "#FFAB00".toColor();
Color errorColor = "#FF5630".toColor();
Color textColor = "#212B36".toColor();
Color subTextColor = "#A6B1BB".toColor();
Color borderColor = "#CED6DE".toColor();

extension ColorExtension on String {
  toColor() {
    var hexColor = replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}
