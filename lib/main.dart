import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

/// Finance Tracker App
/// 
/// A premium offline-first finance tracking application featuring:
/// - Glassmorphism UI design
/// - IBM Plex Sans typography
/// - Dark mode with cyan accents
/// - Material 3 components
/// 
/// Based on UI/UX Pro Max fintech design recommendations.
void main() {
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
  
  runApp(const FinanceTrackerApp());
}

/// Root application widget
class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      
      // Apply the premium dark theme
      theme: AppTheme.darkTheme,
      
      // Set the initial screen
      home: const LoginScreen(),
      
      // Define named routes for navigation
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
      
      // Handle unknown routes gracefully
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      },
    );
  }
}
