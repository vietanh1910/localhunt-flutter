class Campaign {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final double radius; // in meters
  final int pointReward;
  final String? wifiName;
  final bool isActive;
  final String? qrCodeValue;

  Campaign({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.pointReward,
    this.wifiName,
    required this.isActive,
    required this.qrCodeValue
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      radius: (json['radius'] ?? 100.0).toDouble(),
      pointReward: json['point_reward'] ?? 0,
      wifiName: json['wifi_name'],
      isActive: json['is_active'] ?? true,
      qrCodeValue: json['qr_code_value'] ?? ''
    );
  }
}