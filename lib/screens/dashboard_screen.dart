import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_components.dart';
import 'transaction_list_screen.dart';
import 'transaction_form_screen.dart';

/// DashboardScreen - Main home screen with financial overview
/// 
/// Premium fintech dashboard featuring:
/// - Glassmorphism balance card with gradient
/// - Income/Expense stat cards with glow effects
/// - Recent transactions list
/// - Floating action button for quick add
/// 
/// Based on UI/UX Pro Max design system recommendations.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Sample data - will be replaced with actual data from services
  final double _totalBalance = 12450.50;
  final double _totalIncome = 8500.00;
  final double _totalExpense = 3200.00;
  final List<Map<String, dynamic>> _recentTransactions = [
    {
      'title': 'Grocery Shopping',
      'category': 'Food',
      'amount': -125.50,
      'date': 'Today',
      'icon': Icons.shopping_cart,
    },
    {
      'title': 'Salary',
      'category': 'Income',
      'amount': 5000.00,
      'date': 'Yesterday',
      'icon': Icons.work,
    },
    {
      'title': 'Netflix Subscription',
      'category': 'Entertainment',
      'amount': -15.99,
      'date': '2 days ago',
      'icon': Icons.movie,
    },
    {
      'title': 'Freelance Project',
      'category': 'Income',
      'amount': 850.00,
      'date': '3 days ago',
      'icon': Icons.computer,
    },
  ];

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildBalanceCard(),
                        const SizedBox(height: 24),
                        _buildSummaryRow(),
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
                        ..._recentTransactions.map((tx) => TransactionTile(
                          title: tx['title'],
                          category: tx['category'],
                          date: tx['date'],
                          amount: tx['amount'],
                          icon: tx['icon'],
                          onTap: () {
                            // TODO: Navigate to transaction detail
                          },
                        )),
                        const SizedBox(height: 80), // Space for FAB
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
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
                      'John Doe',
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
              // Notification button
              GestureDetector(
                onTap: () {
                  // TODO: Implement notifications
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.glassBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.glassBorder),
                  ),
                  child: Badge(
                    smallSize: 8,
                    backgroundColor: AppTheme.accentPrimary,
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppTheme.textPrimary,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Profile avatar
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to profile/settings
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.accentGradient,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceMedium,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
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
  Widget _buildBalanceCard() {
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
                  // Sync status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_done_outlined,
                          size: 14,
                          color: AppTheme.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Synced',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Balance amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentPrimary,
                    ),
                  ),
                  Text(
                    _totalBalance.toStringAsFixed(2).split('.')[0],
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1,
                    ),
                  ),
                  Text(
                    '.${_totalBalance.toStringAsFixed(2).split('.')[1]}',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Mini stats row
              Row(
                children: [
                  Expanded(child: _buildMiniStat('This Month', '+\$2,340.00', true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMiniStat('Last Month', '+\$1,890.00', false)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mini stat widget inside balance card
  Widget _buildMiniStat(String label, String value, bool isHighlighted) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppTheme.success.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted
              ? AppTheme.success.withOpacity(0.2)
              : AppTheme.glassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isHighlighted ? AppTheme.success : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Income/Expense summary row
  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Income',
            value: '\$${_totalIncome.toStringAsFixed(2)}',
            icon: Icons.arrow_downward_rounded,
            color: AppTheme.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Expense',
            value: '\$${_totalExpense.toStringAsFixed(2)}',
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
              children: [
                const Text(
                  'See All',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.accentPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
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
