import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_components.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'transaction_form_screen.dart';

/// TransactionListScreen - All transactions view
/// 
/// Displays a filterable list of all transactions with:
/// - Search functionality
/// - Filter chips (All, Income, Expense)
/// - Glassmorphism transaction tiles
/// - Pull to refresh
/// 
/// Connected to TransactionProvider for local SQLite data.
class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  /// Get filtered transactions from provider
  List<TransactionModel> _getFilteredTransactions(TransactionProvider provider) {
    List<TransactionModel> result = provider.filterByType(_selectedFilter);
    
    // Apply search
    if (_searchController.text.isNotEmpty) {
      result = provider.search(_searchController.text);
      // Re-apply type filter on search results
      if (_selectedFilter != 'All') {
        result = result.where((t) =>
            _selectedFilter == 'Income' ? !t.isExpense : t.isExpense).toList();
      }
    }
    return result;
  }

  /// Get relative date string
  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(transactionDate).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    return DateFormat('MMM d').format(date);
  }

  /// Get icon for category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'utilities':
        return Icons.flash_on;
      case 'health':
        return Icons.medical_services;
      case 'income':
        return Icons.work;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
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
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, _) => Text(
                'Transactions (${provider.transactions.length})',
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
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
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accentPrimary),
          );
        }

        final transactions = _getFilteredTransactions(provider);
        
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
                  _searchController.text.isNotEmpty
                      ? 'No matching transactions'
                      : 'No transactions yet',
                  style: const TextStyle(
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
          onRefresh: () => provider.loadTransactions(),
          color: AppTheme.accentPrimary,
          backgroundColor: AppTheme.surfaceMedium,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return TransactionTile(
                title: tx.title,
                category: tx.category,
                date: _getRelativeDate(tx.date),
                amount: tx.displayAmount,
                icon: _getCategoryIcon(tx.category),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionFormScreen(transaction: tx),
                    ),
                  );
                  if (result == true && mounted) {
                    provider.loadTransactions();
                  }
                },
              );
            },
          ),
        );
      },
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
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TransactionFormScreen(),
            ),
          );
          if (result == true && mounted) {
            context.read<TransactionProvider>().loadTransactions();
          }
        },
        backgroundColor: AppTheme.accentPrimary,
        foregroundColor: AppTheme.primaryDark,
        elevation: 0,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
