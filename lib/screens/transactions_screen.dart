import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../formatage/widgets/transaction_item.dart';
import '../providers/wallet_provider.dart';
import '../models/transaction.dart';
import '../utils/app_theme.dart';


class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionType? _filter;

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    List<Transaction> filtered = wallet.transactions;
    if (_filter != null) {
      filtered = filtered.where((t) => t.type == _filter).toList();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Historique', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              children: [
                _FilterChip(label: 'Tout', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                const SizedBox(width: 10),
                _FilterChip(
                  label: 'Transfert',
                  selected: _filter == TransactionType.transfer,
                  onTap: () => setState(() => _filter = TransactionType.transfer),
                  color: AppTheme.accent,
                ),
                const SizedBox(width: 10),
                _FilterChip(
                  label: 'Dépôt',
                  selected: _filter == TransactionType.deposit,
                  onTap: () => setState(() => _filter = TransactionType.deposit),
                  color: AppTheme.success,
                ),
                const SizedBox(width: 10),
                _FilterChip(
                  label: 'Achat',
                  selected: _filter == TransactionType.purchase,
                  onTap: () => setState(() => _filter = TransactionType.purchase),
                  color: const Color(0xFF339AF0),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
              child: Text('Aucune transaction', style: TextStyle(color: AppTheme.textSecondary)),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final tx = filtered[i];
                final showDate = i == 0 ||
                    !_isSameDay(filtered[i - 1].date, tx.date);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showDate) ...[
                      if (i > 0) const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          _formatDate(tx.date),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TransactionItem(transaction: tx),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return "Aujourd'hui";
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) return 'Hier';
    return DateFormat('d MMMM yyyy', 'fr_FR').format(date);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c.withOpacity(0.2) : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? c : const Color(0xFF2A2A4A), width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? c : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}