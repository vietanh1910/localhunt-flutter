class User {
  final int id;
  final String email;
  final String fullName;
  final int points; // số Xu

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.points,
  });

  // Parse từ JSON trả về từ backend
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      points: json['points'] ?? 0,
    );
  }

  // Convert sang JSON (nếu cần gửi user lên BE)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'points': points,
    };
  }

  // copyWith để update một số field mà ko cần tạo object mới từ đầu
  User copyWith({
    int? id,
    String? email,
    String? fullName,
    int? points,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      points: points ?? this.points,
    );
  }
}
