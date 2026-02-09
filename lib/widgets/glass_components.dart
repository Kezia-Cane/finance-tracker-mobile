import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// GlassCard - Premium glassmorphism card widget
/// 
/// A reusable card component implementing the glassmorphism effect
/// with backdrop blur, subtle borders, and layered shadows.
/// 
/// Based on UI/UX Pro Max "Glassmorphism" style guidelines:
/// - Semi-transparent background
/// - Backdrop blur effect
/// - Subtle white border (1px solid rgba white 0.2)
/// - Light reflection gradient
class GlassCard extends StatelessWidget {
  /// Child widget to display inside the card
  final Widget child;
  
  /// Padding inside the card
  final EdgeInsetsGeometry padding;
  
  /// Margin around the card
  final EdgeInsetsGeometry? margin;
  
  /// Border radius of the card
  final double borderRadius;
  
  /// Background color opacity (0.0 - 1.0)
  final double backgroundOpacity;
  
  /// Whether to show the gradient overlay
  final bool showGradient;
  
  /// Callback when card is tapped
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 20,
    this.backgroundOpacity = 0.1,
    this.showGradient = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: AppTheme.accentPrimary.withOpacity(0.1),
              highlightColor: AppTheme.accentPrimary.withOpacity(0.05),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(backgroundOpacity),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: AppTheme.glassBorder,
                    width: 1,
                  ),
                  gradient: showGradient
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.05),
                          ],
                        )
                      : null,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// GlassButton - Premium glassmorphism button
/// 
/// A stylish button with glass effect and accent glow
class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isPrimary;
  final double? width;
  final double height;

  const GlassButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isPrimary = true,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppTheme.durationMedium,
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: isPrimary ? AppTheme.accentGradient : null,
        color: isPrimary ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: isPrimary
            ? null
            : Border.all(color: AppTheme.glassBorder, width: 1.5),
        boxShadow: isPrimary ? AppTheme.accentGlow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: isPrimary
                          ? AppTheme.primaryDark
                          : AppTheme.accentPrimary,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 20,
                          color: isPrimary
                              ? AppTheme.primaryDark
                              : AppTheme.textPrimary,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isPrimary
                              ? AppTheme.primaryDark
                              : AppTheme.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// GlassTextField - Premium glassmorphism text field
/// 
/// A styled text input with glass background effect
class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        fontFamily: 'IBMPlexSans',
        color: AppTheme.textPrimary,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppTheme.textSecondary)
            : null,
        suffixIcon: suffixIcon,
        labelStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          color: AppTheme.textSecondary,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          color: AppTheme.textMuted,
        ),
        filled: true,
        fillColor: AppTheme.glassBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.accentPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.error, width: 2),
        ),
        errorStyle: const TextStyle(
          fontFamily: 'IBMPlexSans',
          color: AppTheme.errorLight,
        ),
      ),
      validator: validator,
    );
  }
}

/// StatCard - Summary statistic card with icon
/// 
/// Used for displaying income/expense summaries on dashboard
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool showGlow;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container with glow
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: showGlow
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          // Value
          Text(
            value,
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// TransactionTile - Transaction list item
/// 
/// Displays a single transaction with category icon and amount
class TransactionTile extends StatelessWidget {
  final String title;
  final String category;
  final String date;
  final double amount;
  final IconData icon;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = amount > 0;
    final color = isIncome ? AppTheme.success : AppTheme.error;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          // Category icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$category • $date',
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            '${isIncome ? '+' : ''}\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
