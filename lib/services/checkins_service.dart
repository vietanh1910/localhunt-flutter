import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CheckInService {
  static const String baseUrl = "http://172.20.10.6:8080";
  static const _storage = FlutterSecureStorage();

  /// ==== CREATE CHECK-IN ====
  static Future<bool> createCheckIn({
    required int campaignId,
    required int points,
    bool verify = true
  }) async {
    final url = Uri.parse('$baseUrl/api/check-ins');
    final token = await _storage.read(key: 'access_token');
    print("token: $token");

    final body = jsonEncode({
      "campaignId": campaignId,
      "points": points,
      "verify": verify,
    });

    final res = await http.post(url, headers:
        {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: body);

    if (res.statusCode == 200) {
      return true;
    } else {
      print("❌ Check-in API failed: ${res.statusCode} ${res.body}");
      throw Exception("Check-in failed: ${res.statusCode}");
    }
  }

  /// ==== GET USER CHECK-INS ====
  static Future<List<dynamic>> getUserCheckIns(int userId) async {
    final url = Uri.parse('$baseUrl/api/checkins/user/$userId');
    final token = await _storage.read(key: 'access_token');

    final headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["data"] ?? [];
    } else {
      throw Exception("Failed to load check-ins");
    }
  }

  /// ==== GET CHECK-INS BY CAMPAIGN ====
  static Future<List<dynamic>> getCampaignCheckIns(int campaignId) async {
    final url = Uri.parse('$baseUrl/api/checkins/campaign/$campaignId');
    final token = await _storage.read(key: 'access_token');

    final headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["data"] ?? [];
    } else {
      throw Exception("Failed to load campaign check-ins");
    }
  }
}
