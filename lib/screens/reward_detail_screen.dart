// file: screens/reward_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/voucher.dart';

class RewardDetailScreen extends StatelessWidget {
  final Voucher voucher;
  final int userCoins;
  final Function(Voucher) onRedeem; // Callback khi đổi voucher

  const RewardDetailScreen({
    Key? key,
    required this.voucher,
    required this.userCoins,
    required this.onRedeem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool canAfford = userCoins >= voucher.cost;
    final bool isOutOfStock = voucher.quantity <= 0;
    final bool canRedeem = canAfford && !isOutOfStock;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Voucher'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              voucher.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.card_giftcard, size: 100, color: Colors.grey[400]),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 32.0),
                  Text(
                    'Điều khoản và Điều kiện:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    voucher.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const Divider(height: 32.0),
                  _buildInfoRow(context, icon: Icons.monetization_on, color: Colors.orange, label: 'Giá đổi', value: '${voucher.cost} Xu'),
                  const SizedBox(height: 12.0),
                  _buildInfoRow(context, icon: Icons.inventory_2, color: Colors.green, label: 'Số lượng còn lại', value: isOutOfStock ? 'Hết hàng' : voucher.quantity.toString()),
                  const SizedBox(height: 12.0),
                  _buildInfoRow(context, icon: Icons.person, color: Colors.purple, label: 'Lượt đã đổi', value: voucher.claimed.toString()),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: canRedeem
              ? () {
            onRedeem(voucher);
            // Sau khi đổi, tự động quay lại màn hình trước
            Navigator.of(context).pop();
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            disabledBackgroundColor: Colors.grey.shade400,
          ),
          child: Text(isOutOfStock ? 'Hết Hàng' : 'Đổi Ngay'),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required Color color, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 16.0),
        Text('$label:', style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}