import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/storage.dart';
import 'screens/auth/login_screen.dart';
import 'screens/worker/dashboard.dart';
import 'screens/provider/dashboard.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/role_selection/role_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage().init();
  
  // Create default admin if not exists
  final users = LocalStorage().getUsers();
  final adminExists = users.any((u) => u.username == 'admin');
  if (!adminExists) {
    // We'll create the admin logic in Login screen or here. Let's rely on standard logic.
  }
  
  runApp(const SheWorksApp());
}

class SheWorksApp extends StatelessWidget {
  const SheWorksApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SheWorks Safe',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

// Wrapper to decide initial route based on session
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    final user = LocalStorage().currentUser;
    if (user == null) {
      return const LoginScreen();
    }
    
    // Route based on role
    switch (user.role) {
      case 'worker':
        return const WorkerDashboard();
      case 'provider':
        return const ProviderDashboard();
      case 'admin':
        return const AdminDashboard();
      default:
        return const RoleSelectionScreen();
    }
  }
}
