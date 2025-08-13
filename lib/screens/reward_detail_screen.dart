// file: screens/reward_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/reward.dart';

class RewardDetailScreen extends StatelessWidget {
  final Reward reward;
  // Nhận các tham số mới từ RewardScreen
  final int userCoins;
  final VoidCallback onRedeem; // VoidCallback là kiểu hàm không tham số, không trả về giá trị

  const RewardDetailScreen({
    Key? key,
    required this.reward,
    required this.userCoins, // Yêu cầu phải có khi khởi tạo
    required this.onRedeem,    // Yêu cầu phải có khi khởi tạo
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tính toán các điều kiện để quyết định có cho phép đổi hay không
    final bool isOutOfStock = reward.quantity == 0;
    final bool hasReachedLimit = reward.timesRedeemedByUser >= reward.redemptionLimit;
    final bool canAfford = userCoins >= reward.cost;
    // Tổng hợp lại điều kiện cuối cùng
    final bool canRedeem = !isOutOfStock && !hasReachedLimit && canAfford;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Phần Thưởng'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              reward.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.card_giftcard, size: 100, color: Colors.grey),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 32.0),
                  Text(
                    'Điều khoản và Điều kiện:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    reward.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                  const Divider(height: 32.0),
                  _buildInfoRow(
                    context,
                    icon: Icons.monetization_on,
                    color: Colors.orange,
                    label: 'Giá đổi',
                    value: '${reward.cost} Xu',
                  ),
                  const SizedBox(height: 12.0),
                  _buildInfoRow(
                    context,
                    icon: Icons.inventory_2,
                    color: Colors.green,
                    label: 'Số lượng còn lại',
                    value: reward.quantity > 0 ? reward.quantity.toString() : 'Hết hàng',
                  ),
                  const SizedBox(height: 12.0),
                  _buildInfoRow(
                    context,
                    icon: Icons.repeat_one,
                    color: Colors.purple,
                    label: 'Giới hạn đổi của bạn',
                    value: '${reward.timesRedeemedByUser}/${reward.redemptionLimit}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // THÊM MỚI: Thanh chứa nút bấm ở dưới cùng màn hình
      bottomNavigationBar: Padding(
        // Thêm padding để nút không bị dính vào cạnh màn hình
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: ElevatedButton(
          // Dựa vào điều kiện `canRedeem` để bật/tắt nút
          onPressed: canRedeem ? onRedeem : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            // Style cho nút khi bị vô hiệu hóa
            disabledBackgroundColor: Colors.grey.shade400,
          ),
          child: const Text('Đổi Ngay'),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required Color color, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 16.0),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}