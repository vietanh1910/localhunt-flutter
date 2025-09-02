// File: lib/models/redemption_history_item.dart
import 'package:authen/models/voucher.dart';   // Đảm bảo đường dẫn đúng
import 'package:authen/enums/redemption_status.dart'; // Đảm bảo đường dẫn đúng

class RedemptionHistoryItem {
  final int id;
  final Voucher voucher;
  final DateTime redeemedAt;
  final RedemptionStatus status;

  final String? currentQrCode;
  final DateTime? qrExpiryTime;
  final String? qrImageBase64;

  RedemptionHistoryItem({
    required this.id,
    required this.voucher,
    required this.redeemedAt,
    required this.status,
    this.currentQrCode,
    this.qrExpiryTime,
    this.qrImageBase64,
  });

  // Factory method đã được làm cho an toàn hơn
  factory RedemptionHistoryItem.fromJson(Map<String, dynamic> json) {
    // Sử dụng các hàm trợ giúp để parse an toàn
    final int parsedId = _parseInt(json['id']);
    final DateTime parsedRedeemedAt = _parseDateTime(json['redeemedAt']);
    final RedemptionStatus parsedStatus = parseRedemptionStatus(json['status']);

    // Xử lý đối tượng voucher lồng nhau, cung cấp giá trị mặc định nếu null
    final Voucher parsedVoucher = json['voucher'] != null
        ? Voucher.fromJson(json['voucher'] as Map<String, dynamic>)
        : Voucher(id: -1, name: 'Lỗi Voucher', description: '', imageUrl: '', cost: 0, quantity: 0, claimed: 0); // Voucher mặc định khi có lỗi

    // Xử lý đối tượng latestQr lồng nhau
    final Map<String, dynamic>? latestQrJson = json['latestQr'] as Map<String, dynamic>?;

    return RedemptionHistoryItem(
      id: parsedId,
      voucher: parsedVoucher,
      redeemedAt: parsedRedeemedAt,
      status: parsedStatus,
      currentQrCode: latestQrJson?['code'] as String?,
      qrImageBase64: latestQrJson?['qrImageBase64'] as String?,
      qrExpiryTime: _parseDateTime(latestQrJson?['expiryDate']), // Dùng lại hàm parse an toàn
    );
  }

  // --- CÁC HÀM TRỢ GIÚP PARSE AN TOÀN ---

  // Parse một giá trị có thể là null hoặc sai kiểu sang int
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0; // Giá trị mặc định
  }

  // Parse một giá trị có thể là null hoặc chuỗi không hợp lệ sang DateTime
  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime(1970); // Trả về một ngày mặc định nếu parse lỗi
    }
    // Trả về một ngày mặc định nếu giá trị là null hoặc sai kiểu
    return DateTime(1970);
  }
}