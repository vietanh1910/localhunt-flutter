// File: lib/services/auth_api.dart


import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:authen/models/user.dart';

class AuthApi {
  static const String BASE_URL = 'http://10.0.2.2:8080/api';

  static const _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Xây dựng URL đầy đủ
    final uri = Uri.parse('$BASE_URL/auth/signin');

    try {
      final body = jsonEncode({"email": email, "password": password});
      final headers = {HttpHeaders.contentTypeHeader: "application/json"};

      print(">>> Calling Login API: $uri");
      print(">>> With body: $body");

      final response = await http.post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 20));

      final responseBody = json.decode(utf8.decode(response.bodyBytes));

      // Thành công
      if (response.statusCode == 200) {
        final token = responseBody['token'] as String?;

        // Tạo đối tượng User từ JSON
        // Dòng này sẽ hết báo lỗi sau khi bạn đã import file user_model.dart
        final user = User.fromJson(responseBody);

        if (token != null) {
          await _storage.write(key: 'access_token', value: token);
        }

        return {"ok": true, "token": token, "user": user};
      }

      // Thất bại
      String errorMessage = responseBody['error'] ?? responseBody['message'] ?? 'Đăng nhập thất bại.';
      print("<<< Login failed with status ${response.statusCode}: $errorMessage");
      return {"ok": false, "error": errorMessage};

    } catch (e) {
      // Lỗi kết nối
      print("<<< Login API Exception: $e");
      return {"ok": false, "error": "Không thể kết nối. Vui lòng kiểm tra lại mạng."};
    }
  }
}