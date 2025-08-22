// file: screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/redemption_history_item.dart';

class HistoryScreen extends StatelessWidget {
  final List<RedemptionHistoryItem> history;

  const HistoryScreen({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedHistory = List<RedemptionHistoryItem>.from(history)..sort((a, b) => b.redemptionDate.compareTo(a.redemptionDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Đổi Thưởng'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: sortedHistory.isEmpty
          ? const Center(
        child: Text(
          'Bạn chưa đổi phần thưởng nào.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: sortedHistory.length,
        itemBuilder: (context, index) {
          final item = sortedHistory[index];

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
                'Ngày đổi: ${DateFormat('HH:mm, dd/MM/yyyy').format(item.redemptionDate)}',
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