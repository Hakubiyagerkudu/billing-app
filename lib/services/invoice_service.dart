import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kontor/utils/endpoints.dart';
import 'package:kontor/utils/pref_data.dart';

class InvoiceService {
  static Future<dynamic> getInvoiceStatistic() async {
    final token = await PrefData.getAccessToken();
    final response = await http.get(
      Uri.parse(Endpoints.invoiceYearly),
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

  static Future<dynamic> getInvoiceList(String type, int page) async {
    final token = await PrefData.getAccessToken();
    final response = await http.get(
      Uri.parse(Endpoints.invoiceList(type, page)),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded["status"] == "ok") {
        return {
          "status": true,
          "num_pages": decoded["result"]["num_pages"],
          "data": decoded["result"]["data"]
        };
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

  static Future<dynamic> getInvoiceDetail(String invoiceId) async {
    final token = await PrefData.getAccessToken();
    var body = {"invoice_id": invoiceId};
    final response = await http.post(
      Uri.parse(Endpoints.invoiceDetails),
      body: body,
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

  static Future<dynamic> checkUserRegister(String register) async {
    final response = await http.get(
      Uri.parse(Endpoints.checkUserRegister(register)),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded["status"] == "ok") {
        return {"status": true};
      } else {
        return {"status": false, "error": decoded["message"]};
      }
    } else {
      return {"status": false, "error": "Оролдлого амжилтгүй"};
    }
  }

  static Future<dynamic> getQpayInvoice(
      List<dynamic> invoiceIds, String userType, userRegister) async {
    final token = await PrefData.getAccessToken();
    final body = json.encode({
      "ids": invoiceIds,
      "user_type": userType,
      "user_register": userRegister,
    });

    final response = await http.post(
      Uri.parse(Endpoints.qpayInvoice),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json", // important!
      },
      body: body,
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

  static Future<bool> checkPayment(String url) async {
    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      if (response.body == "ok") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
