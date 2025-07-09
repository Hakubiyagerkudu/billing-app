import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kontor/utils/endpoints.dart';
import 'package:kontor/utils/pref_data.dart';

class AuthService {
  static Future<bool> login(String userCode, password) async {
    var body = {"username": userCode, "password": password};
    final response = await http.post(Uri.parse(Endpoints.login), body: body);

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded["status"] == "ok") {
        final accessToken = decoded['access_token'];
        final userData = decoded['user_data'];

        // Save access token
        await PrefData.setString(PrefData.accessTokenKey, accessToken);

        // Convert userData map to JSON string and save it
        final userDataJson = json.encode(userData);
        await PrefData.setString(PrefData.userDataKey, userDataJson);

        return userData["verified"];
      } else {
        throw decoded["message"];
      }
    } else {
      final error = json.decode(utf8.decode(response.bodyBytes));
      throw error["message"];
    }
  }

  static Future<void> logout() async {
    await PrefData.remove(PrefData.userDataKey);
    await PrefData.remove(PrefData.accessTokenKey);
  }

  static Future<bool> register(
      String firstName, lastName, email, phone, password) async {
    final token = await PrefData.getAccessToken();
    var body = {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "password": password
    };
    final response = await http.post(
      Uri.parse(Endpoints.login),
      body: body,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded["status"] == "ok") {
        var userData = await PrefData.getUserData();
        userData["verified"] = false;

        final userDataJson = json.encode(userData);
        await PrefData.setString(PrefData.userDataKey, userDataJson);

        return true;
      } else {
        throw decoded["message"];
      }
    } else {
      final error = json.decode(utf8.decode(response.bodyBytes));
      throw error["message"];
    }
  }

  static Future<bool> checkUserRegistered(String email) async {
    final response = await http.get(
      Uri.parse(Endpoints.checkUserRegistered(email)),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = json.decode(utf8.decode(response.bodyBytes));
      throw error["message"];
    }
  }

  static Future<bool> editProfile(
      String firstName, lastName, email, phone, ebarimtNo) async {
    final token = await PrefData.getAccessToken();
    var userData = await PrefData.getUserData();
    var body = {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "ebarimt_customer_no": ebarimtNo
    };
    final response = await http.post(
      Uri.parse(Endpoints.editProfile),
      body: body,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      userData["first_name"] = firstName;
      userData["last_name"] = lastName;
      userData["email"] = email;
      userData["phone"] = phone;
      userData["ebarimt_customer_no"] = ebarimtNo;

      final userDataJson = json.encode(userData);
      await PrefData.setString(PrefData.userDataKey, userDataJson);

      return true;
    } else {
      final error = json.decode(utf8.decode(response.bodyBytes));
      throw error["message"];
    }
  }

  static Future<bool> forgotPassword(String code, newPass) async {
    var userData = await PrefData.getUserData();
    var body = {
      "username": userData["username"],
      "code": code,
      "new_password": newPass
    };
    final response = await http.post(
      Uri.parse(Endpoints.forgotPass),
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = json.decode(utf8.decode(response.bodyBytes));
      throw error["message"];
    }
  }

  static Future<bool> changePassword(String oldPass, newPass) async {
    final token = await PrefData.getAccessToken();
    var body = {"old_password": oldPass, "new_password": newPass};
    final response = await http.post(
      Uri.parse(Endpoints.changePass),
      body: body,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final error = json.decode(utf8.decode(response.bodyBytes));
      throw error["message"];
    }
  }
}
