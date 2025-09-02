// File: lib/screens/reward_screen.dart

import 'package:flutter/material.dart';
import '../models/voucher.dart';
import 'reward_detail_screen.dart';

class RewardScreen extends StatelessWidget {
  final List<Voucher> vouchers;
  final int userCoins;
  final Function(Voucher) onRedeem;
  final String token;

  const RewardScreen({
    Key? key,
    required this.vouchers,
    required this.userCoins,
    required this.onRedeem,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (vouchers.isEmpty) {
      return const Center(child: Text("Không có voucher nào khả dụng hoặc đã đổi hết."));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        itemCount: vouchers.length,
        itemBuilder: (context, index) {
          final voucher = vouchers[index];
          return _VoucherCard(
            voucher: voucher,
            userCoins: userCoins,
            onRedeem: onRedeem,
            onViewDetail: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  // Sửa ở đây để gọi đúng VoucherDetailScreen
                  builder: (_) => RewardDetailScreen(
                    voucher: voucher,
                    userCoins: userCoins,
                    onRedeem: onRedeem,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
class _VoucherCard extends StatelessWidget {
  final Voucher voucher;
  final int userCoins;
  final Function(Voucher) onRedeem;
  final VoidCallback onViewDetail;

  const _VoucherCard({
    required this.voucher,
    required this.userCoins,
    required this.onRedeem,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    // Logic kiểm tra có thể đổi hay không
    final bool canRedeem = userCoins >= voucher.cost && (voucher.quantity == 0 || voucher.claimed < voucher.quantity);
    final bool hasImage = voucher.imageUrl.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: hasImage
                      ? Image.network(
                    voucher.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                  )
                      : _buildImagePlaceholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(voucher.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(voucher.description, style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      // === BỎ DÒNG "ĐÃ ĐỔI" VÀ THAY BẰNG SỐ LƯỢNG CÒN LẠI ===
                      Text(
                          'Số lượng còn: ${voucher.quantity - voucher.claimed}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  avatar: const Icon(Icons.monetization_on, color: Colors.orange, size: 18),
                  label: Text(
                    '${voucher.cost} Xu',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: onViewDetail,
                      child: const Text('Chi Tiết'),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: canRedeem ? () => onRedeem(voucher) : null,
                      child: const Text('Đổi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canRedeem ? Colors.blue : Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey.withOpacity(0.1),
      child: Icon(Icons.local_offer, size: 40, color: Colors.grey[400]),
    );
  }
}