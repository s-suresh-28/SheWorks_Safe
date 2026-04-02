import 'package:flutter/material.dart';
import '../../core/storage.dart';
import '../../main.dart';
import '../auth/login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = '';

  void _confirmRole() async {
    if (_selectedRole.isEmpty) return;

    final user = LocalStorage().currentUser;
    if (user != null) {
      final updatedUser = user.copyWith(role: _selectedRole);
      await LocalStorage().saveUser(updatedUser);
      
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (r) => false,
      );
    }
  }

  void _logout() async {
    await LocalStorage().setCurrentUserId(null);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'How would you like to use SheWorks Safe?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _RoleCard(
              title: 'Worker (Job Seeker)',
              description: 'Find safe household jobs nearby.',
              icon: Icons.cleaning_services,
              isSelected: _selectedRole == 'worker',
              onTap: () => setState(() => _selectedRole = 'worker'),
            ),
            const SizedBox(height: 20),
            _RoleCard(
              title: 'Job Provider',
              description: 'Hire verified female workers safely.',
              icon: Icons.home_work,
              isSelected: _selectedRole == 'provider',
              onTap: () => setState(() => _selectedRole = 'provider'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedRole.isEmpty ? null : _confirmRole,
              child: const Text('Confirm Role'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isSelected ? Colors.purple[50] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? Colors.purple : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: isSelected ? Colors.purple : Colors.grey),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(description, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
