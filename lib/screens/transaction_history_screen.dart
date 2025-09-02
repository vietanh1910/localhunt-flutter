// file: screens/transaction_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_history_item.dart';

class TransactionHistoryScreen extends StatelessWidget {
  final List<TransactionHistoryItem> transactions;

  const TransactionHistoryScreen({Key? key, required this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sắp xếp các giao dịch theo thứ tự mới nhất lên đầu
    final sortedTransactions = List<TransactionHistoryItem>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Giao Dịch Xu'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: sortedTransactions.isEmpty
          ? const Center(
        child: Text(
          'Chưa có giao dịch nào.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: sortedTransactions.length,
        itemBuilder: (ctx, index) {
          final item = sortedTransactions[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                // Dùng getter `color` và `icon` từ model
                backgroundColor: item.color.withOpacity(0.15),
                child: Icon(item.icon, color: item.color),
              ),
              title: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                DateFormat('HH:mm, dd/MM/yyyy').format(item.date),
              ),
              trailing: Text(
                // Dùng getter `amountString` từ model
                item.amountString,
                style: TextStyle(
                  color: item.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}