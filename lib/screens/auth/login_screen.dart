import 'package:flutter/material.dart';
import '../../core/storage.dart';
import 'aadhaar_verification_screen.dart';
import '../../main.dart'; // for AuthWrapper
import '../../models/models.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  void _login() async {
    // Admin shortcut
    if (_emailCtrl.text == 'admin' && _passwordCtrl.text == 'admin') {
      final users = LocalStorage().getUsers();
      var admin = users.cast<dynamic>().firstWhere((u) => u.username == 'admin', orElse: () => null);
      if (admin == null) {
        admin = User(
          id: 'admin_id_xyz',
          username: 'admin',
          email: 'admin@sheworks.com',
          password: 'admin',
          role: 'admin',
          isVerifiedFemale: true,
          age: 30,
        );
        await LocalStorage().saveUser(admin);
      }
      await LocalStorage().setCurrentUserId(admin.id);
      _goToWrapper();
      return;
    }

    final users = LocalStorage().getUsers();
    try {
      final user = users.firstWhere(
        (u) => u.email == _emailCtrl.text && u.password == _passwordCtrl.text,
      );
      
      if (user.isBanned) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account has been suspended.')));
        return;
      }

      await LocalStorage().setCurrentUserId(user.id);
      _goToWrapper();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
    }
  }

  void _goToWrapper() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.shield_rounded, size: 80, color: Colors.purple),
            const SizedBox(height: 20),
            const Text(
              'SheWorks Safe',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AadhaarVerificationScreen()),
                );
              },
              child: const Text('New Worker? Verify with Aadhaar to Join'),
            )
          ],
        ),
      ),
    );
  }
}
