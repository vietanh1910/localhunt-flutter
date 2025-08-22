class Campaign {
  final int id;
  final int allocatorId;
  final String name;
  final String description;

  // location
  final String locationName;
  final double latitude;
  final double longitude;
  final int radiusMeters;

  // wifi
  final String? requiredWifiSsid;
  final String? requiredWifiBssid;

  // reward
  final int rewardPerCheckin;   // map từ rewardPerCheckin
  final int? maxCheckinsPerUser;
  final double pointBudget;     // map từ pointBudget
  final double remainingBudget;

  // thời gian
  final DateTime startDate;
  final DateTime endDate;
  final String? startTime;
  final String? endTime;

  // QR Code
  final String? qrUrl;

  // thống kê
  final int used;
  final int checkIns;

  // status
  final String status;
  final String? approvalNotes;
  final int? approvedById;
  final DateTime? approvedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  Campaign({
    required this.id,
    required this.allocatorId,
    required this.name,
    required this.description,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.requiredWifiSsid,
    this.requiredWifiBssid,
    required this.rewardPerCheckin,
    this.maxCheckinsPerUser,
    required this.pointBudget,
    required this.remainingBudget,
    required this.startDate,
    required this.endDate,
    this.startTime,
    this.endTime,
    this.qrUrl,
    required this.used,
    required this.checkIns,
    required this.status,
    this.approvalNotes,
    this.approvedById,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ✅ Parse từ JSON
  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'],
      allocatorId: json['allocatorId'] ?? 0, // backend chưa trả thì gán 0
      name: json['name'] ?? '',
      description: json['description'] ?? '',

      // location object
      locationName: json['locationName'] ?? '',
      latitude: (json['location']?['lat'] ?? 0).toDouble(),
      longitude: (json['location']?['lng'] ?? 0).toDouble(),
      radiusMeters: json['radiusMeters'] ?? 0,

      // wifi object
      requiredWifiSsid: json['wifi']?['ssid'],
      requiredWifiBssid: json['wifi']?['bssid'],

      // reward
      rewardPerCheckin: json['rewardPerCheckin'] ?? 0,
      maxCheckinsPerUser: json['maxCheckinsPerUser'],
      pointBudget: (json['pointBudget'] ?? 0).toDouble(),
      remainingBudget: (json['remainingBudget'] ?? 0).toDouble(),

      // thời gian
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      startTime: json['startTime'],
      endTime: json['endTime'],

      // QR
      qrUrl: json['qrUrl'],

      // thống kê
      used: json['used'] ?? 0,
      checkIns: json['checkIns'] ?? 0,

      // status
      status: json['status'] ?? 'PENDING',
      approvalNotes: json['approvalNotes'],
      approvedById: json['approvedById'],
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,

      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// ✅ Convert sang JSON (nếu cần gửi lên server)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "allocatorId": allocatorId,
      "name": name,
      "description": description,
      "locationName": locationName,
      "location": {
        "lat": latitude,
        "lng": longitude,
      },
      "radiusMeters": radiusMeters,
      "wifi": {
        "ssid": requiredWifiSsid,
        "bssid": requiredWifiBssid,
      },
      "rewardPerCheckin": rewardPerCheckin,
      "maxCheckinsPerUser": maxCheckinsPerUser,
      "pointBudget": pointBudget,
      "remainingBudget": remainingBudget,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
      "startTime": startTime,
      "endTime": endTime,
      "qrUrl": qrUrl,
      "used": used,
      "checkIns": checkIns,
      "status": status,
      "approvalNotes": approvalNotes,
      "approvedById": approvedById,
      "approvedAt": approvedAt?.toIso8601String(),
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}
