import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class UserService {
  static const _storage = FlutterSecureStorage();

  static Future<User> getUserById(int userId) async {
    final token = await _storage.read(key: 'access_token');
    final response = await http.get(
      Uri.parse("http://172.20.10.6:8080/api/users/$userId"), // ✅ truyền id
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to fetch user info: ${response.statusCode}");
    }
  }
}
