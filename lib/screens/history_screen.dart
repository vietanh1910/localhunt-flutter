// file: screens/history_screen.dart

import 'package:flutter/material.dart';
import '../models/redemption_history_item.dart';

class HistoryScreen extends StatelessWidget {
  final List<RedemptionHistoryItem> history;

  const HistoryScreen({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Đổi Thưởng'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: history.isEmpty
          ? const Center(
        child: Text(
          'Bạn chưa đổi phần thưởng nào.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: history.length,
        itemBuilder: (context, index) {
          // Sắp xếp để hiển thị giao dịch mới nhất lên đầu
          final item = history[history.length - 1 - index];
          final hour = item.redemptionDate.hour.toString().padLeft(2, '0');
          final minute = item.redemptionDate.minute.toString().padLeft(2, '0');

          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  item.rewardImageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                item.rewardName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Ngày đổi: $hour:$minute ${item.redemptionDate.day}/${item.redemptionDate.month}/${item.redemptionDate.year}',
              ),
              trailing: Chip(
                label: Text(
                  '-${item.cost} Xu',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.red.shade50,
              ),
            ),
          );
        },
      ),
    );
  }
}