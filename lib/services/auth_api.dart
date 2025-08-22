import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthApi {
  // Đổi URL này cho đúng môi trường:
  // - Android emulator -> dùng 172.16.0.229 trỏ về localhost của máy host
  // - iOS simulator    -> dùng 127.0.0.1 hoặc host.docker.internal
  static const String BASE_URL = 'http://172.20.10.6:8080';
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$BASE_URL/api/auth/signin'); // đổi path cho phù hợp
    final body = jsonEncode({
      "email": email,               // hoặc "username" tuỳ backend
      "password": password
    });

    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.acceptHeader: "application/json",
    };

    final res = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 15));

    // Ví dụ backend trả:
    // { "accessToken": "...", "refreshToken": "...", "tokenType": "Bearer" }
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;

      final access = data['token'] as String?;

      if (access != null) {
        await _storage.write(key: 'access_token', value: access);
      }

      return {"ok": true, "data": data};
    }

    // gom thông điệp lỗi thân thiện
    String message = 'Đăng nhập thất bại (${res.statusCode})';
    try {
      final err = jsonDecode(res.body);
      if (err is Map && err['message'] is String) {
        message = err['message'];
      } else if (err is Map && err['error'] is String) {
        message = err['error'];
      }
    } catch (_) {}
    return {"ok": false, "error": message};
  }
}
