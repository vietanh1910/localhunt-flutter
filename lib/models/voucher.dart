// File: lib/models/voucher.dart

class Voucher {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final int cost;
  final int quantity;
  final int claimed; // <-- THÊM DÒNG NÀY

  Voucher({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.cost,
    required this.quantity,
    required this.claimed, // <-- THÊM VÀO CONSTRUCTOR
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'] ?? 0,
      name: json['title'] ?? 'Voucher không có tên',
      description: json['description'] ?? 'Không có mô tả chi tiết.',
      imageUrl: json['imageUrl'] ?? '',
      cost: json['pointCost'] ?? 0,
      quantity: json['quantity'] ?? 0,
      claimed: json['claimed'] ?? 0, // <-- ĐỌC 'claimed' TỪ JSON
    );
  }
}