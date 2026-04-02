import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../core/storage.dart';
import '../role_selection/role_selection_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final int age;
  final bool isVerifiedFemale;

  const SignupScreen({
    Key? key,
    required this.age,
    required this.isVerifiedFemale,
  }) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  void _signup() async {
    if (_emailCtrl.text.isEmpty || _usernameCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields')));
      return;
    }

    final users = LocalStorage().getUsers();
    if (users.any((u) => u.email == _emailCtrl.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email already exists')));
      return;
    }

    final newUser = User(
      id: const Uuid().v4(),
      username: _usernameCtrl.text,
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      role: 'none',
      isVerifiedFemale: widget.isVerifiedFemale,
      age: widget.age,
    );

    await LocalStorage().saveUser(newUser);
    await LocalStorage().setCurrentUserId(newUser.id);

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome safely,',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Verified Female, Age ${widget.age}', style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 30),
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _signup,
              child: const Text('Sign Up'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Already have an account? Login'),
            )
          ],
        ),
      ),
    );
  }
}
