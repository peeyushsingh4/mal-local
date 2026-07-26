import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _prefKey = 'user_detected_location_v1';

  /// Get saved location or default prompt
  static Future<String> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null && saved.trim().isNotEmpty) {
      return saved;
    }
    return 'Detecting location...';
  }

  /// Save custom user location
  static Future<void> saveLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, location.trim());
  }

  /// Detect location via IP Geolocation API (Works on Web & Mobile without native permission popups)
  static Future<String> detectCurrentLocation() async {
    try {
      final response = await http.get(Uri.parse('https://ipapi.co/json/')).timeout(
        const Duration(seconds: 4),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final city = data['city'] ?? '';
        final region = data['region'] ?? '';
        final result = city.isNotEmpty ? '$city, $region' : 'Current Location';
        await saveLocation(result);
        return result;
      }
    } catch (_) {
      // Fallback if network/timeout occurs
    }
    return 'Current Location';
  }
}
