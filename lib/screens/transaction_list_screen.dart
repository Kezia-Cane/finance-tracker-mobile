import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_components.dart';
import 'transaction_form_screen.dart';

/// TransactionListScreen - All transactions view
/// 
/// Displays a filterable list of all transactions with:
/// - Search functionality
/// - Filter chips (All, Income, Expense)
/// - Glassmorphism transaction tiles
/// - Pull to refresh
class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  
  // Sample data - will be replaced with actual data from services
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'title': 'Grocery Shopping',
      'category': 'Food',
      'amount': -125.50,
      'date': 'Today',
      'fullDate': '2024-01-15',
      'icon': Icons.shopping_cart,
    },
    {
      'title': 'Salary',
      'category': 'Income',
      'amount': 5000.00,
      'date': 'Yesterday',
      'fullDate': '2024-01-14',
      'icon': Icons.work,
    },
    {
      'title': 'Netflix Subscription',
      'category': 'Entertainment',
      'amount': -15.99,
      'date': '2 days ago',
      'fullDate': '2024-01-13',
      'icon': Icons.movie,
    },
    {
      'title': 'Freelance Project',
      'category': 'Income',
      'amount': 850.00,
      'date': '3 days ago',
      'fullDate': '2024-01-12',
      'icon': Icons.computer,
    },
    {
      'title': 'Electric Bill',
      'category': 'Utilities',
      'amount': -89.00,
      'date': '4 days ago',
      'fullDate': '2024-01-11',
      'icon': Icons.flash_on,
    },
    {
      'title': 'Coffee Shop',
      'category': 'Food',
      'amount': -12.50,
      'date': '5 days ago',
      'fullDate': '2024-01-10',
      'icon': Icons.coffee,
    },
    {
      'title': 'Investment Returns',
      'category': 'Income',
      'amount': 320.00,
      'date': '1 week ago',
      'fullDate': '2024-01-08',
      'icon': Icons.trending_up,
    },
    {
      'title': 'Gas Station',
      'category': 'Transport',
      'amount': -45.00,
      'date': '1 week ago',
      'fullDate': '2024-01-07',
      'icon': Icons.local_gas_station,
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    return _allTransactions.where((tx) {
      // Apply filter
      if (_selectedFilter == 'Income' && tx['amount'] < 0) return false;
      if (_selectedFilter == 'Expense' && tx['amount'] > 0) return false;
      
      // Apply search
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        return tx['title'].toLowerCase().contains(query) ||
            tx['category'].toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: Stack(
        children: [
          _buildBackgroundEffects(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildFilterChips(),
                const SizedBox(height: 16),
                Expanded(child: _buildTransactionList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  /// Background gradient effects
  Widget _buildBackgroundEffects() {
    return Positioned(
      top: 150,
      right: -100,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppTheme.accentPrimary.withOpacity(0.1),
              AppTheme.accentPrimary.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }

  /// Header with back button and title
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.glassBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Transactions',
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          // Filter/Sort button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.glassBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppTheme.textPrimary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Search bar with glass effect
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.glassBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppTheme.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSans',
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search transactions...',
                      hintStyle: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        color: AppTheme.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Filter chips for All/Income/Expense
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: ['All', 'Income', 'Expense'].map((filter) {
          final isSelected = _selectedFilter == filter;
          final color = filter == 'Income'
              ? AppTheme.success
              : filter == 'Expense'
                  ? AppTheme.error
                  : AppTheme.accentPrimary;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: AppTheme.durationFast,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.15) : AppTheme.glassBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? color.withOpacity(0.5) : AppTheme.glassBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? color : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Transaction list with pull to refresh
  Widget _buildTransactionList() {
    final transactions = _filteredTransactions;
    
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Implement refresh logic
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppTheme.accentPrimary,
      backgroundColor: AppTheme.surfaceMedium,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return TransactionTile(
            title: tx['title'],
            category: tx['category'],
            date: tx['date'],
            amount: tx['amount'],
            icon: tx['icon'],
            onTap: () {
              // TODO: Navigate to transaction detail/edit
            },
          );
        },
      ),
    );
  }

  /// Floating action button
  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.accentGlow,
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TransactionFormScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.accentPrimary,
        foregroundColor: AppTheme.primaryDark,
        elevation: 0,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
