import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _prefix = 'notegym:';

  StorageService._();

  static String _key(String key) => '$_prefix$key';

  static Future<T?> get<T>(String key, {T? fallback}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(key));
      if (raw == null) return fallback;
      return jsonDecode(raw) as T;
    } catch (_) {
      return fallback;
    }
  }

  static Future<bool> set<T>(String key, T value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key(key), jsonEncode(value));
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key(key));
      return true;
    } catch (_) {
      return false;
    }
  }
}
