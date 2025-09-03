// File: lib/services/voucher_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/voucher.dart';

class VoucherService {
  // ===>>> THAY 192.168.1.13 BẰNG IP CỦA BẠN
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  static Future<List<Voucher>> fetchVouchers(String token) async {
    final uri = Uri.parse('$baseUrl/vouchers');
    try {
      final response = await http.get(
        uri,
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
        return body.map((json) => Voucher.fromJson(json)).toList();
      } else {
        throw Exception("Không thể tải danh sách voucher (Lỗi: ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Lỗi kết nối khi tải voucher. Vui lòng thử lại.");
    }
  }

  static Future<void> redeemVoucher(int voucherId, String token) async {
    final uri = Uri.parse('$baseUrl/vouchers/$voucherId/redeem');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['error'] ?? 'Lỗi không xác định khi đổi voucher.');
      }
    } catch (e) {
      rethrow;
    }
  }
}