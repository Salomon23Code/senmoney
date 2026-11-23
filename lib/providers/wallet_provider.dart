import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/user_model.dart';

class WalletProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  // Current user
  final UserModel _currentUser = UserModel(
    id: 'user_001',
    name: 'Amadou Diallo',
    phone: '+221 77 123 45 67',
    email: 'amadou.diallo@email.com',
    balance: 125000.0,
  );

  // Transactions list
  final List<Transaction> _transactions = [
    Transaction(
      id: 'tx_001',
      type: TransactionType.deposit,
      amount: 50000,
      description: 'Dépôt initial',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Transaction(
      id: 'tx_002',
      type: TransactionType.transfer,
      amount: 15000,
      description: 'Transfert vers Fatou',
      recipientName: 'Fatou Sow',
      recipientPhone: '+221 76 987 65 43',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Transaction(
      id: 'tx_003',
      type: TransactionType.purchase,
      amount: 8500,
      description: 'Achat - Orange Money Shop',
      merchantName: 'Orange Money Shop',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Transaction(
      id: 'tx_004',
      type: TransactionType.deposit,
      amount: 75000,
      description: 'Rechargement Wave',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction(
      id: 'tx_005',
      type: TransactionType.purchase,
      amount: 3200,
      description: 'Achat - Touba Gas',
      merchantName: 'Touba Gas',
      date: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // Mock contacts
  final List<Contact> _contacts = [
    Contact(id: 'c1', name: 'Fatou Sow', phone: '+221 76 987 65 43'),
    Contact(id: 'c2', name: 'Moussa Ba', phone: '+221 77 234 56 78'),
    Contact(id: 'c3', name: 'Aissatou Fall', phone: '+221 70 345 67 89'),
    Contact(id: 'c4', name: 'Ibrahim Ndiaye', phone: '+221 78 456 78 90'),
    Contact(id: 'c5', name: 'Mariama Diop', phone: '+221 76 567 89 01'),
    Contact(id: 'c6', name: 'Ousmane Gaye', phone: '+221 77 678 90 12'),
  ];

  // Mock merchants
  final List<Merchant> _merchants = const [
    Merchant(id: 'm1', name: 'Orange Money Shop', category: 'Télécoms', icon: '📱'),
    Merchant(id: 'm2', name: 'Touba Gas', category: 'Carburant', icon: '⛽'),
    Merchant(id: 'm3', name: 'Auchan Dakar', category: 'Supermarché', icon: '🛒'),
    Merchant(id: 'm4', name: 'Pharmacie du Plateau', category: 'Santé', icon: '💊'),
    Merchant(id: 'm5', name: 'CityDia', category: 'Supermarché', icon: '🏪'),
    Merchant(id: 'm6', name: 'SenElec', category: 'Électricité', icon: '⚡'),
    Merchant(id: 'm7', name: 'SDE', category: 'Eau', icon: '💧'),
    Merchant(id: 'm8', name: 'Expresso', category: 'Télécoms', icon: '📡'),
  ];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel get currentUser => _currentUser;
  double get balance => _currentUser.balance;
  List<Transaction> get transactions => List.unmodifiable(_transactions.reversed.toList());
  List<Contact> get contacts => List.unmodifiable(_contacts);
  List<Merchant> get merchants => List.unmodifiable(_merchants);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Statistics
  double get totalDeposits => _transactions
      .where((t) => t.type == TransactionType.deposit)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalSpent => _transactions
      .where((t) => t.type != TransactionType.deposit)
      .fold(0, (sum, t) => sum + t.amount);

  List<Transaction> getRecentTransactions({int limit = 5}) {
    final sorted = [..._transactions]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  // Transfer method
  Future<bool> transfer({
    required Contact recipient,
    required double amount,
    String? note,
  }) async {
    if (amount <= 0) {
      _errorMessage = 'Le montant doit être supérieur à 0';
      notifyListeners();
      return false;
    }
    if (amount > _currentUser.balance) {
      _errorMessage = 'Solde insuffisant';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    _currentUser.balance -= amount;
    _transactions.add(Transaction(
      id: _uuid.v4(),
      type: TransactionType.transfer,
      amount: amount,
      description: note?.isNotEmpty == true ? note! : 'Transfert vers ${recipient.name}',
      recipientName: recipient.name,
      recipientPhone: recipient.phone,
      date: DateTime.now(),
    ));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Deposit method
  Future<bool> deposit({
    required double amount,
    required String method,
  }) async {
    if (amount <= 0) {
      _errorMessage = 'Le montant doit être supérieur à 0';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _currentUser.balance += amount;
    _transactions.add(Transaction(
      id: _uuid.v4(),
      type: TransactionType.deposit,
      amount: amount,
      description: 'Dépôt via $method',
      date: DateTime.now(),
    ));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Purchase method
  Future<bool> purchase({
    required Merchant merchant,
    required double amount,
    String? description,
  }) async {
    if (amount <= 0) {
      _errorMessage = 'Le montant doit être supérieur à 0';
      notifyListeners();
      return false;
    }
    if (amount > _currentUser.balance) {
      _errorMessage = 'Solde insuffisant';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _currentUser.balance -= amount;
    _transactions.add(Transaction(
      id: _uuid.v4(),
      type: TransactionType.purchase,
      amount: amount,
      description: description?.isNotEmpty == true ? description! : 'Achat - ${merchant.name}',
      merchantName: merchant.name,
      date: DateTime.now(),
    ));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}