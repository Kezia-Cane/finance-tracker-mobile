import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'providers/transaction_provider.dart';
import 'services/database_service.dart';

/// Finance Tracker App
/// 
/// A premium offline-first finance tracking application featuring:
/// - Glassmorphism UI design
/// - IBM Plex Sans typography
/// - Dark mode with cyan accents
/// - Local SQLite storage (offline-first)
/// 
/// Cloud sync via Supabase can be enabled later.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style for immersive dark mode
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surfaceDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize local database
  await DatabaseService.database;
  
  runApp(const FinanceTrackerApp());
}

/// Root application widget
class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Finance Tracker',
        debugShowCheckedModeBanner: false,
        
        // Apply the premium dark theme
        theme: AppTheme.darkTheme,
        
        // Start directly on Dashboard for local-first mode
        home: const DashboardScreen(),
      ),
    );
  }
}
