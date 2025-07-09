import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PrefData {
  static const String rememberedUserCodeKey = "remembered_user_code";
  static const String accessTokenKey = "access_token";
  static const String userDataKey = "user_data";

  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // ----------------- Generic Helpers -----------------
  static Future<void> setString(String key, String value) async {
    (await _getPrefs()).setString(key, value);
  }

  static Future<String> getString(String key, [String defaultVal = ""]) async {
    return (await _getPrefs()).getString(key) ?? defaultVal;
  }

  static Future<void> setInt(String key, int value) async {
    (await _getPrefs()).setInt(key, value);
  }

  static Future<int> getInt(String key, [int defaultVal = 0]) async {
    return (await _getPrefs()).getInt(key) ?? defaultVal;
  }

  static Future<void> setBool(String key, bool value) async {
    (await _getPrefs()).setBool(key, value);
  }

  static Future<bool> getBool(String key, [bool defaultVal = false]) async {
    return (await _getPrefs()).getBool(key) ?? defaultVal;
  }

  static Future<void> remove(String key) async {
    (await _getPrefs()).remove(key);
  }

  // ----------------- Typed Getters/Setters -----------------

  static Future<void> setRememberedUserCode(String userCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (userCode.isEmpty) {
      prefs.remove(rememberedUserCodeKey);
    } else {
      prefs.setString(rememberedUserCodeKey, userCode);
    }
  }

  static Future<String> getRememberedUserCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(rememberedUserCodeKey) ?? '';
  }

  static Future<void> setPageNumber(String key, int value) =>
      setInt(key, value);

  static Future<int> getPageNumber(String key) => getInt(key, 1);

  static Future<String> getAccessToken() => getString(accessTokenKey);

  static Future<void> setCacheList(String key, List<dynamic> data) async {
    final prefs = await _getPrefs();
    final jsonList = data.map((e) => e.toJson()).toList();
    prefs.setString(key, json.encode(jsonList));
  }

  static Future<Map<String, dynamic>> getUserData() async {
    final userDataString = await PrefData.getString(userDataKey);
    if (userDataString.isEmpty) return {};
    return json.decode(userDataString);
  }
}
