import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../formatage/widgets/success_overlay.dart';
import '../providers/wallet_provider.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';


class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  Merchant? _selectedMerchant;
  String _amountDisplay = '0';
  final _descController = TextEditingController();

  void _appendDigit(String digit) {
    setState(() {
      if (_amountDisplay == '0') {
        _amountDisplay = digit;
      } else if (_amountDisplay.length < 9) {
        _amountDisplay += digit;
      }
    });
  }

  void _deleteDigit() {
    setState(() {
      if (_amountDisplay.length > 1) {
        _amountDisplay = _amountDisplay.substring(0, _amountDisplay.length - 1);
      } else {
        _amountDisplay = '0';
      }
    });
  }

  double get _amount => double.tryParse(_amountDisplay) ?? 0;

  Future<void> _confirmPurchase() async {
    if (_selectedMerchant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un marchand')),
      );
      return;
    }
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant')),
      );
      return;
    }

    final wallet = context.read<WalletProvider>();
    final success = await wallet.purchase(
      merchant: _selectedMerchant!,
      amount: _amount,
      description: _descController.text,
    );

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => SuccessOverlay(
          title: 'Achat confirmé!',
          message: '${formatAmount(_amount)} FCFA payés à ${_selectedMerchant!.name}',
          icon: Icons.shopping_bag_rounded,
          iconColor: AppTheme.primary,
          onDone: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      );
    } else if (mounted && wallet.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(wallet.errorMessage!), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Achat', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choisir un marchand',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Merchants grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: wallet.merchants.length,
                    itemBuilder: (context, i) {
                      final merchant = wallet.merchants[i];
                      final isSelected = _selectedMerchant?.id == merchant.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMerchant = merchant),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary.withOpacity(0.2)
                                : AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppTheme.primary : const Color(0xFF2A2A4A),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(merchant.icon, style: const TextStyle(fontSize: 26)),
                              const SizedBox(height: 6),
                              Text(
                                merchant.name.split(' ').first,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Amount
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '${formatAmount(_amount)} FCFA',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_selectedMerchant != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_selectedMerchant!.icon} ${_selectedMerchant!.name}',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Solde: ${formatAmount(wallet.balance)} FCFA',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _descController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Description (optionnel)',
                      prefixIcon: Icon(Icons.receipt_rounded, color: AppTheme.textSecondary),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildNumpad(),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF339AF0)),
                onPressed: wallet.isLoading ? null : _confirmPurchase,
                child: wallet.isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Payer'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0', '⌫'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: keys.length,
      itemBuilder: (context, i) {
        final key = keys[i];
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            if (key == '⌫') {
              _deleteDigit();
            } else {
              for (final c in key.split('')) {
                _appendDigit(c);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: key == '⌫' ? const Color(0xFF339AF0).withOpacity(0.2) : AppTheme.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2A2A4A)),
            ),
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  color: key == '⌫' ? const Color(0xFF339AF0) : AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}