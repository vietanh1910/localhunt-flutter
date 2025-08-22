import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/campaign.dart';

class CampaignService {
  static const String baseUrl = "http://172.20.10.6:8080"; // Android Emulator
  static const _storage = FlutterSecureStorage();

  // ==== GET ALL CAMPAIGNS ====
  static Future<List<Campaign>> getCampaigns({double? lat, double? lon}) async {
    final url = Uri.parse('$baseUrl/api/campaigns/get-all');
    final token = await _storage.read(key: 'access_token');

    final body = json.encode({
      "latitude": lat,
      "longitude": lon
    });

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> list = data["data"]["items"];
      return list.map((e) => Campaign.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load campaigns");
    }
  }

  // ==== GET CAMPAIGN DETAIL ====
  static Future<Campaign> getCampaignById(int id) async {
    final url = Uri.parse('$baseUrl/api/campaigns/$id');
    final token = await _storage.read(key: 'access_token');

    final headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is Map && data['data'] != null) {
        return Campaign.fromJson(data['data']);
      }
      return Campaign.fromJson(data);
    } else {
      throw Exception("Failed to load campaign detail");
    }
  }

  // ==== CREATE CAMPAIGN ====
  static Future<bool> createCampaign(Campaign campaign) async {
    final url = Uri.parse('$baseUrl/api/campaigns');
    final token = await _storage.read(key: 'access_token');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final res = await http.post(
      url,
      headers: headers,
      body: jsonEncode(campaign.toJson()),
    );

    return res.statusCode == 200;
  }

  // ==== DELETE CAMPAIGN ====
  static Future<bool> deleteCampaign(int id) async {
    final url = Uri.parse('$baseUrl/api/campaigns/$id');
    final token = await _storage.read(key: 'access_token');

    final headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final res = await http.delete(url, headers: headers);
    return res.statusCode == 200;
  }
}
