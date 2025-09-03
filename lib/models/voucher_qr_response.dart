// File: lib/models/voucher_qr_response.dart
import 'dart:convert';

class VoucherQrResponse {
  final String code;
  final String qrImageBase64;
  final DateTime expiryDate;
  final String status;

  VoucherQrResponse({
    required this.code,
    required this.qrImageBase64,
    required this.expiryDate,
    required this.status,
  });

  factory VoucherQrResponse.fromJson(Map<String, dynamic> json) {
    return VoucherQrResponse(
      code: json['code'] ?? '',
      qrImageBase64: json['qrImageBase64'] ?? '',
      expiryDate: DateTime.parse(json['expiryDate']),
      status: json['status'] ?? 'UNKNOWN',
    );
  }
}