// file: models/transaction_history_item.dart

import 'package:flutter/material.dart';

enum TransactionType {
  earn,
  spend,
}

class TransactionHistoryItem {
  final String title;
  final int amount;
  final TransactionType type;
  final DateTime date;

  TransactionHistoryItem({
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
  });

  Color get color => type == TransactionType.earn ? Colors.green : Colors.red;
  IconData get icon => type == TransactionType.earn ? Icons.arrow_upward : Icons.arrow_downward;
  String get amountString => type == TransactionType.earn ? '+${amount} Xu' : '-${amount} Xu';
}