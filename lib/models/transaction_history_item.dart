// File: lib/models/transaction_history_item.dart
import 'package:flutter/material.dart';

class TransactionHistoryItem {
  final String title;
  final DateTime date;
  final int amount; // Dùng int để tính toán, sau đó định dạng thành string

  TransactionHistoryItem({
    required this.title,
    required this.date,
    required this.amount,
  });

  // Getter để định dạng chuỗi hiển thị
  String get amountString {
    return amount > 0 ? '+ $amount Xu' : '- ${amount.abs()} Xu';
  }

  // Getter để quyết định màu sắc
  Color get color {
    return amount >= 0 ? Colors.green : Colors.red;
  }
  // Getter để quyết định icon
  IconData get icon {
    return amount >= 0 ? Icons.add_card : Icons.shopping_cart_checkout;
  }
}