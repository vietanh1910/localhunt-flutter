class MockApiService {
  static Future<bool> checkIn(String campaignId, double lat, double lng) async {
    await Future.delayed(const Duration(seconds: 1)); // Giả lập gọi API
    print('✅ Mock Check-in success with: '
        'Campaign ID: $campaignId, Lat: $lat, Lng: $lng');
    return true; // Luôn thành công
  }
}
