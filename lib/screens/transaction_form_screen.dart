import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_components.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

/// TransactionFormScreen - Add/Edit transaction interface
/// 
/// A form screen for creating or editing transactions with:
/// - Transaction type toggle (Income/Expense)
/// - Amount input with large display
/// - Category selection grid
/// - Date picker
/// - Notes field
/// 
/// Connected to TransactionProvider for local SQLite storage.
class TransactionFormScreen extends StatefulWidget {
  /// The transaction to edit (null for new transaction)
  final TransactionModel? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isExpense = true;
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Category options with icons
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Transport', 'icon': Icons.directions_car},
    {'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'name': 'Entertainment', 'icon': Icons.movie},
    {'name': 'Utilities', 'icon': Icons.flash_on},
    {'name': 'Health', 'icon': Icons.medical_services},
    {'name': 'Income', 'icon': Icons.work},
    {'name': 'Investment', 'icon': Icons.trending_up},
    {'name': 'Other', 'icon': Icons.category},
  ];

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.durationMedium,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // Pre-fill if editing
    if (_isEditing) {
      final tx = widget.transaction!;
      _titleController.text = tx.title;
      _amountController.text = tx.amount.toStringAsFixed(2);
      _isExpense = tx.isExpense;
      _selectedCategory = tx.category;
      _selectedDate = tx.date;
      _notesController.text = tx.notes ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Handle form submission
  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final provider = context.read<TransactionProvider>();
        final amount = double.parse(_amountController.text);

        if (_isEditing) {
          // Update existing transaction
          final updated = widget.transaction!.copyWith(
            title: _titleController.text.trim(),
            amount: amount,
            category: _selectedCategory,
            notes: _notesController.text.trim().isEmpty 
                ? null 
                : _notesController.text.trim(),
            date: _selectedDate,
            isExpense: _isExpense,
          );
          await provider.updateTransaction(updated);
        } else {
          // Create new transaction
          await provider.addTransaction(
            title: _titleController.text.trim(),
            amount: amount,
            category: _selectedCategory,
            notes: _notesController.text.trim().isEmpty 
                ? null 
                : _notesController.text.trim(),
            date: _selectedDate,
            isExpense: _isExpense,
          );
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing ? 'Transaction updated!' : 'Transaction added!',
                style: const TextStyle(fontFamily: 'IBMPlexSans'),
              ),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context, true); // Return true to signal refresh
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to save: ${e.toString()}',
                style: const TextStyle(fontFamily: 'IBMPlexSans'),
              ),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  /// Handle delete
  Future<void> _handleDelete() async {
    if (!_isEditing) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Transaction?',
          style: TextStyle(
            fontFamily: 'IBMPlexSans',
            color: AppTheme.textPrimary,
          ),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(
            fontFamily: 'IBMPlexSans',
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                color: AppTheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await context.read<TransactionProvider>().deleteTransaction(
          widget.transaction!.id,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Transaction deleted',
                style: TextStyle(fontFamily: 'IBMPlexSans'),
              ),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  /// Show date picker
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentPrimary,
              surface: AppTheme.surfaceMedium,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: Stack(
        children: [
          _buildBackgroundEffects(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTypeToggle(),
                            const SizedBox(height: 24),
                            _buildAmountInput(),
                            const SizedBox(height: 24),
                            _buildTitleInput(),
                            const SizedBox(height: 24),
                            _buildCategoryGrid(),
                            const SizedBox(height: 24),
                            _buildDatePicker(),
                            const SizedBox(height: 24),
                            _buildNotesInput(),
                            const SizedBox(height: 32),
                            _buildSubmitButton(),
                            if (_isEditing) ...[
                              const SizedBox(height: 16),
                              _buildDeleteButton(),
                            ],
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Background gradient effects
  Widget _buildBackgroundEffects() {
    return Stack(
      children: [
        Positioned(
          top: 100,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (_isExpense ? AppTheme.error : AppTheme.success)
                      .withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Header with back and title
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
                Icons.close_rounded,
                color: AppTheme.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _isEditing ? 'Edit Transaction' : 'Add Transaction',
              style: const TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Income/Expense toggle
  Widget _buildTypeToggle() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Row(
            children: [
              _buildToggleButton('Expense', true, AppTheme.error),
              _buildToggleButton('Income', false, AppTheme.success),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isExpenseType, Color color) {
    final isSelected = _isExpense == isExpenseType;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isExpense = isExpenseType),
        child: AnimatedContainer(
          duration: AppTheme.durationFast,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: color.withOpacity(0.4))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isExpenseType
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: isSelected ? color : AppTheme.textMuted,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Large amount input
  Widget _buildAmountInput() {
    final color = _isExpense ? AppTheme.error : AppTheme.success;
    
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Amount',
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$',
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              IntrinsicWidth(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid amount';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Must be > 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Title/description input
  Widget _buildTitleInput() {
    return GlassTextField(
      controller: _titleController,
      label: 'Title',
      hint: 'e.g., Grocery shopping',
      prefixIcon: Icons.edit_outlined,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
    );
  }

  /// Category selection grid
  Widget _buildCategoryGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category['name'];
            final color = _isExpense ? AppTheme.accentPrimary : AppTheme.success;
            
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category['name']),
              child: AnimatedContainer(
                duration: AppTheme.durationFast,
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.15)
                      : AppTheme.glassBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? color.withOpacity(0.5)
                        : AppTheme.glassBorder,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'],
                      color: isSelected ? color : AppTheme.textSecondary,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'],
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? color : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Date picker field
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentPrimary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: AppTheme.accentPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMMM d, yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// Notes input field
  Widget _buildNotesInput() {
    return GlassTextField(
      controller: _notesController,
      label: 'Notes (Optional)',
      hint: 'Add any additional details...',
      prefixIcon: Icons.notes_outlined,
      maxLines: 3,
    );
  }

  /// Submit button
  Widget _buildSubmitButton() {
    return GlassButton(
      text: _isEditing ? 'Update Transaction' : 'Save Transaction',
      onPressed: _handleSubmit,
      isLoading: _isLoading,
      icon: Icons.check_rounded,
      width: double.infinity,
    );
  }

  /// Delete button (only for editing)
  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _handleDelete,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.error.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.error,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Delete Transaction',
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
