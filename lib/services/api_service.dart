import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/campaign.dart';

class ApiService {
  static const String baseUrl = 'http://your-api-url.com/api'; // Replace with your API URL
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Future<List<Campaign>> getCampaigns() async {
    return [Campaign(
      id: '1',
      name: 'Highlands Coffee Cầu Giấy',
      description: 'Check-in tại Highlands Coffee để nhận 50 điểm thưởng',
      address: '123 Cầu Giấy, Hà Nội',
      latitude: 21.037317703669025,
      longitude: 105.74916635664299,
      radius: 50.0,
      pointReward: 50,
      wifiName: 'Highlands_CauGiay',
      isActive: true,
      qrCodeValue: 'TEST1234', // Mã QR hợp lệ để test
    ),
    Campaign(
      id: '2',
      name: 'Vincom Center',
      description: 'Ghé thăm Vincom Center và nhận ngay 30 điểm thưởng',
      address: '191 Bà Triệu, Hai Bà Trưng, Hà Nội',
      latitude: 21.0145,
      longitude: 105.8469,
      radius: 100.0,
      pointReward: 30,
      wifiName: 'Vincom_Free',
      isActive: true,
      qrCodeValue: 'TEST1234', // Mã QR hợp lệ để test
    ),
    Campaign(
      id: '3',
      name: 'Circle K Láng Hạ',
      description: 'Check-in tại Circle K để nhận 20 điểm thưởng',
      address: '456 Láng Hạ, Ba Đình, Hà Nội',
      latitude: 21.0167,
      longitude: 105.8210,
      radius: 30.0,
      pointReward: 20,
      wifiName: 'CircleK_LangHa',
      isActive: true,
      qrCodeValue: 'TEST1234', // Mã QR hợp lệ để test
    ),
      Campaign(
        id: '4',
        name: 'Cao đẳng FPT',
        description: 'Check-in tại Cao đẳng FPT để nhận 20 điểm thưởng',
        address: '456 Láng Hạ, Ba Đình, Hà Nội',
        latitude: 21.038182,
        longitude: 105.7472931,
        radius: 30.0,
        pointReward: 20,
        wifiName: 'CircleK_LangHa',
        isActive: true,
        qrCodeValue: 'TEST1234', // Mã QR hợp lệ để test
      )];
    // try {
    //   final response = await http.get(
    //     Uri.parse('$baseUrl/campaigns'),
    //     headers: {
    //       'Content-Type': 'application/json',
    //       if (_token != null) 'Authorization': 'Bearer $_token',
    //     },
    //   );

    //   if (response.statusCode == 200) {
    //     final List<dynamic> data = json.decode(response.body);
    //     return data.map((json) => Campaign.fromJson(json)).toList();
    //   } else {
    //     throw Exception('Failed to load campaigns');
    //   }
    // } catch (e) {
    //   print('Error fetching campaigns: $e');
    //   // Return mock data for development
    //   return _getMockCampaigns();
    // }
  }

  static Future<bool> checkIn(String campaignId, double lat, double lng) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/checkin'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'campaign_id': campaignId,
          'latitude': lat,
          'longitude': lng,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error during check-in: $e');
      return false;
    }
  }

  // Mock data for development/testing
  static List<Campaign> _getMockCampaigns() {
    return [
      Campaign(
        id: '1',
        name: 'Highlands Coffee Cầu Giấy',
        description: 'Check-in tại quán cà phê Highlands Coffee để nhận 50 điểm thưởng!',
        address: '123 Đường Cầu Giấy, Hà Nội',
        latitude: 21.0227,
        longitude: 105.8194,
        radius: 30.0,
        pointReward: 20,
        isActive: true,
        qrCodeValue: 'TEST1234', // Mã QR hợp lệ để test
      ),
    ];
  }
}
