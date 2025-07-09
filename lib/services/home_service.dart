import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kontor/utils/endpoints.dart';
import 'package:kontor/utils/pref_data.dart';

class HomeService {
  static Future<dynamic> getApartmentInfo() async {
    final token = await PrefData.getAccessToken();
    final response = await http.get(
      Uri.parse(Endpoints.apartment),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));

      if (decoded["status"] == "ok") {
        return {"status": true, "data": decoded["result"]};
      } else {
        throw {
          "status": false,
          "error": decoded["message"],
        };
      }
    } else {
      final error = json.decode(utf8.decode(response.bodyBytes));
      throw {
        "status": false,
        "error": error["message"],
      };
    }
  }

  static Future<dynamic> getInvoiceMonthlyData() async {
    final now = DateTime.now();
    int currentYear = now.year;

    if (now.month == 1) currentYear = currentYear - 1;

    final token = await PrefData.getAccessToken();
    final response = await http.get(
      Uri.parse(Endpoints.invoiceMonthly(currentYear)),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded["status"] == "ok") {
        return {"status": true, "data": decoded["result"]};
      } else {
        throw {
          "status": false,
          "error": decoded["message"],
        };
      }
    } else {
      final error = json.decode(utf8.decode(response.bodyBytes));
      throw {
        "status": false,
        "error": error["message"],
      };
    }
  }
}
