import 'package:flutter/material.dart';
import '../../core/storage.dart';
import '../auth/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  void _logout() async {
    await LocalStorage().setCurrentUserId(null);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (r) => false,
    );
  }

  void _banUser(String userId) async {
    final users = LocalStorage().getUsers();
    final idx = users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final user = users[idx];
      await LocalStorage().saveUser(user.copyWith(isBanned: true));
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${user.username} banned permanently.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = LocalStorage().getUsers().where((u) => u.role != 'admin').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard & Conflicts'),
        backgroundColor: Colors.red[800],
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red[50],
            width: double.infinity,
            child: const Text(
              'System Alert: Ban users with rating < 2.0',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (ctx, i) {
                final user = users[i];
                final isWarning = user.rating < 2.0;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.isBanned ? Colors.grey : (isWarning ? Colors.red : Colors.green),
                    child: Icon(user.role == 'worker' ? Icons.cleaning_services : Icons.home_work, color: Colors.white),
                  ),
                  title: Text('${user.username} (${user.role.toUpperCase()})'),
                  subtitle: Text('Rating: ${user.rating} ⭐ | Banned: ${user.isBanned}'),
                  trailing: user.isBanned 
                    ? const Text('BANNED', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                    : IconButton(
                        icon: const Icon(Icons.block, color: Colors.red),
                        onPressed: () => _banUser(user.id),
                        tooltip: 'Ban User',
                      ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
