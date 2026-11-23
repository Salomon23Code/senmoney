import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../formatage/widgets/success_overlay.dart';
import '../providers/wallet_provider.dart';
import '../utils/app_theme.dart';


class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  String _selectedMethod = 'Wave';
  String _amountDisplay = '0';

  final List<Map<String, dynamic>> _methods = [
    {'name': 'Wave', 'icon': '🌊', 'color': Color(0xFF00D2FF)},
    {'name': 'Orange Money', 'icon': '🟠', 'color': Color(0xFFFF6B00)},
    {'name': 'Free Money', 'icon': '💚', 'color': Color(0xFF00C853)},
    {'name': 'Carte bancaire', 'icon': '💳', 'color': Color(0xFF6C63FF)},
  ];

  final List<double> _quickAmounts = [5000, 10000, 25000, 50000, 100000];

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

  Future<void> _confirmDeposit() async {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant')),
      );
      return;
    }

    final wallet = context.read<WalletProvider>();
    final success = await wallet.deposit(amount: _amount, method: _selectedMethod);

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => SuccessOverlay(
          title: 'Dépôt réussi!',
          message: '${formatAmount(_amount)} FCFA ajoutés à votre portefeuille',
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
        title: const Text('Dépôt', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  // Method selection
                  const Text(
                    'Méthode de dépôt',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.8,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: _methods.length,
                    itemBuilder: (context, i) {
                      final method = _methods[i];
                      final isSelected = _selectedMethod == method['name'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMethod = method['name']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (method['color'] as Color).withOpacity(0.2)
                                : AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? method['color'] as Color : const Color(0xFF2A2A4A),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(method['icon'], style: TextStyle(fontSize: 20) , ),
                              const SizedBox(width: 8),
                              Text(
                                method['name'],
                                style: TextStyle(
                                  color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                                  fontSize: 13,
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

                  // Amount display
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
                        Text(
                          'Solde actuel: ${formatAmount(wallet.balance)} FCFA',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick amounts
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: _quickAmounts.map((a) {
                      return GestureDetector(
                        onTap: () => setState(() => _amountDisplay = a.toInt().toString()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF2A2A4A)),
                          ),
                          child: Text(
                            '${formatAmount(a)} F',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Numpad
                  _buildNumpad(),
                ],
              ),
            ),
          ),

          // Confirm button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                onPressed: wallet.isLoading ? null : _confirmDeposit,
                child: wallet.isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Déposer'),
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
              color: key == '⌫' ? AppTheme.success.withOpacity(0.2) : AppTheme.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2A2A4A)),
            ),
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  color: key == '⌫' ? AppTheme.success : AppTheme.textPrimary,
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