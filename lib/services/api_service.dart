// File: lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:authen/models/voucher.dart';
import 'package:authen/models/voucher_qr_response.dart';
import 'package:authen/models/redemption_history_item.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api';
  String? _authToken;

  // Constructor để có thể tạo instance và truyền token vào
  ApiService();

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> _getHeaders() {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Hàm xử lý lỗi tập trung để tránh lặp code
  Exception _handleError(http.Response response) {
    try {
      final errorBody = json.decode(utf8.decode(response.bodyBytes));
      final errorMessage = errorBody['error'] ?? 'Lỗi không xác định từ server.';
      return Exception(errorMessage);
    } catch (e) {
      return Exception('Lỗi xử lý yêu cầu: ${response.statusCode}');
    }
  }

  // Lấy danh sách voucher CÓ THỂ ĐỔI (cho RewardScreen)
  Future<List<Voucher>> getAvailableVouchers() async {
    final url = Uri.parse('$_baseUrl/vouchers');
    final response = await http.get(url, headers: _getHeaders());
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Voucher.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw _handleError(response);
    }
  }

  // Lấy lịch sử voucher ĐÃ ĐỔI (cho HistoryScreen)
  Future<List<RedemptionHistoryItem>> getMyRedeemedVouchers(int userId) async {
    final url = Uri.parse('$_baseUrl/history/my-vouchers/$userId'); // Thêm userId vào URL
    final response = await http.get(url, headers: _getHeaders());
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => RedemptionHistoryItem.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw _handleError(response);
    }
  }

  // Đổi voucher
  Future<void> redeemVoucher({required int voucherId}) async {
    final url = Uri.parse('$_baseUrl/vouchers/$voucherId/redeem');
    final response = await http.post(url, headers: _getHeaders());

    // Chỉ cần kiểm tra mã lỗi, không cần trả về gì nếu thành công
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _handleError(response);
    }
  }

  // Lấy hoặc tạo mã QR
  Future<VoucherQrResponse> getOrCreateVoucherQr({
    required int voucherId,
    required int userId,
  }) async {
    final url = Uri.parse('$_baseUrl/voucher-qr/get-or-create?voucherId=$voucherId&userId=$userId');
    final response = await http.post(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      return VoucherQrResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw _handleError(response);
    }
  }

  // Kiểm tra trạng thái của mã QR
  Future<VoucherQrResponse> getQrStatus(String code) async {
    final url = Uri.parse('$_baseUrl/voucher-qr/status/$code');
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      return VoucherQrResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw _handleError(response);
    }
  }
}