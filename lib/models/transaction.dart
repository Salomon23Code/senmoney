import 'package:flutter/material.dart';

enum TransactionType { transfer, deposit, purchase }

enum TransactionStatus { pending, completed, failed }

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final String? recipientName;
  final String? recipientPhone;
  final String? merchantName;
  final DateTime date;
  final TransactionStatus status;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    this.recipientName,
    this.recipientPhone,
    this.merchantName,
    required this.date,
    this.status = TransactionStatus.completed,
  });

  IconData get icon {
    switch (type) {
      case TransactionType.transfer:
        return Icons.send_rounded;
      case TransactionType.deposit:
        return Icons.account_balance_wallet_rounded;
      case TransactionType.purchase:
        return Icons.shopping_bag_rounded;
    }
  }

  Color get color {
    switch (type) {
      case TransactionType.transfer:
        return const Color(0xFFFF6B6B);
      case TransactionType.deposit:
        return const Color(0xFF51CF66);
      case TransactionType.purchase:
        return const Color(0xFF339AF0);
    }
  }

  bool get isCredit => type == TransactionType.deposit;

  String get typeLabel {
    switch (type) {
      case TransactionType.transfer:
        return 'Transfert';
      case TransactionType.deposit:
        return 'Dépôt';
      case TransactionType.purchase:
        return 'Achat';
    }
  }
}