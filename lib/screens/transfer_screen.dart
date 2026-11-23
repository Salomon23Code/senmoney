import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../formatage/widgets/success_overlay.dart';
import '../providers/wallet_provider.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';


class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  Contact? _selectedContact;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _amountDisplay = '0';

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

  Future<void> _confirmTransfer() async {
    if (_selectedContact == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un destinataire')),
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
    final success = await wallet.transfer(
      recipient: _selectedContact!,
      amount: _amount,
      note: _noteController.text,
    );

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => SuccessOverlay(
          title: 'Transfert réussi!',
          message: '${formatAmount(_amount)} FCFA envoyés à ${_selectedContact!.name}',
          onDone: () {
            Navigator.of(context).pop(); // close dialog
            Navigator.of(context).pop(); // go back
          },
        ),
      );
    } else if (mounted && wallet.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wallet.errorMessage!),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Transfert', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  // Contacts
                  const Text(
                    'Choisir le destinataire',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: wallet.contacts.length,
                      itemBuilder: (context, i) {
                        final contact = wallet.contacts[i];
                        final isSelected = _selectedContact?.id == contact.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedContact = contact),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(
                                      colors: [AppTheme.primary, AppTheme.secondary],
                                    )
                                        : null,
                                    color: isSelected ? null : AppTheme.cardBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? AppTheme.primary : const Color(0xFF2A2A4A),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      contact.initials,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  contact.name.split(' ').first,
                                  style: TextStyle(
                                    color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
                          'Solde: ${formatAmount(wallet.balance)} FCFA',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Note field
                  TextField(
                    controller: _noteController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Note (optionnel)',
                      prefixIcon: Icon(Icons.note_rounded, color: AppTheme.textSecondary),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Numpad
                  _buildNumpad(),
                ],
              ),
            ),
          ),

          // Send button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: wallet.isLoading ? null : _confirmTransfer,
                child: wallet.isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Envoyer'),
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
              color: key == '⌫' ? AppTheme.primary.withOpacity(0.2) : AppTheme.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2A2A4A)),
            ),
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  color: key == '⌫' ? AppTheme.primary : AppTheme.textPrimary,
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