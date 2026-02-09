import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_components.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'transaction_list_screen.dart';
import 'transaction_form_screen.dart';

/// DashboardScreen - Main home screen with financial overview
/// 
/// Premium fintech dashboard featuring:
/// - Glassmorphism balance card with gradient
/// - Income/Expense stat cards with glow effects
/// - Recent transactions list from local SQLite
/// - Floating action button for quick add
/// 
/// Connected to TransactionProvider for local-first data.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AppTheme.durationMedium,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();

    // Load transactions on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Format currency value
  String _formatCurrency(double value) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);
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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: Stack(
        children: [
          // Background effects
          _buildBackgroundEffects(size),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Consumer<TransactionProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accentPrimary,
                      ),
                    );
                  }

                  return CustomScrollView(
                    slivers: [
                      _buildAppBar(),
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildBalanceCard(provider),
                            const SizedBox(height: 24),
                            _buildSummaryRow(provider),
                            const SizedBox(height: 32),
                            _buildSectionHeader(
                              'Recent Transactions',
                              onSeeAll: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TransactionListScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (provider.recentTransactions.isEmpty)
                              _buildEmptyState()
                            else
                              ...provider.recentTransactions.map((tx) => 
                                _buildTransactionTile(tx)),
                            const SizedBox(height: 80), // Space for FAB
                          ]),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  /// Empty state when no transactions
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.glassBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No transactions yet',
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first transaction',
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build transaction tile from model
  Widget _buildTransactionTile(TransactionModel tx) {
    return TransactionTile(
      title: tx.title,
      category: tx.category,
      date: _getRelativeDate(tx.date),
      amount: tx.displayAmount,
      icon: _getCategoryIcon(tx.category),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionFormScreen(transaction: tx),
          ),
        );
      },
    );
  }

  /// Decorative background effects
  Widget _buildBackgroundEffects(Size size) {
    return Stack(
      children: [
        Positioned(
          top: 100,
          right: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accentPrimary.withOpacity(0.15),
                  AppTheme.accentPrimary.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 300,
          left: -60,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.success.withOpacity(0.12),
                  AppTheme.success.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Custom app bar with user greeting
  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              // App logo
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentPrimary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppTheme.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Text(
                      'Local User',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Settings button
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to settings
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.glassBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.glassBorder),
                  ),
                  child: const Icon(
                    Icons.settings_outlined,
                    color: AppTheme.textPrimary,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Premium balance card with glassmorphism
  Widget _buildBalanceCard(TransactionProvider provider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accentPrimary.withOpacity(0.2),
                AppTheme.accentSecondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.glassBorder),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentPrimary.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  // Local mode badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.info.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phone_android,
                          size: 14,
                          color: AppTheme.info,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Local',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Balance amount
              Text(
                _formatCurrency(provider.totalBalance),
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 24),
              // Transaction count
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${provider.transactions.length} transactions',
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Income/Expense summary row
  Widget _buildSummaryRow(TransactionProvider provider) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Income',
            value: _formatCurrency(provider.totalIncome),
            icon: Icons.arrow_downward_rounded,
            color: AppTheme.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Expense',
            value: _formatCurrency(provider.totalExpense),
            icon: Icons.arrow_upward_rounded,
            color: AppTheme.error,
          ),
        ),
      ],
    );
  }

  /// Section header with "See All" button
  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Row(
              children: const [
                Text(
                  'See All',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.accentPrimary,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppTheme.accentPrimary,
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Floating action button with glow
  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.accentGlow,
      ),
      child: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TransactionFormScreen(),
            ),
          );
          // Refresh if a transaction was added
          if (result == true && mounted) {
            context.read<TransactionProvider>().loadTransactions();
          }
        },
        backgroundColor: AppTheme.accentPrimary,
        foregroundColor: AppTheme.primaryDark,
        elevation: 0,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Transaction',
          style: TextStyle(
            fontFamily: 'IBMPlexSans',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
