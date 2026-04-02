import 'package:flutter/material.dart';
import '../../core/storage.dart';
import '../../main.dart'; // For AuthWrapper
import '../auth/login_screen.dart';
import 'job_search_screen.dart';
import 'profile_screen.dart';
import '../shared/chat_screen.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({Key? key}) : super(key: key);

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  int _currentIndex = 0;

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
    final screens = [
      _WorkerHome(onSearchRequested: () => setState(() => _currentIndex = 1)),
      const JobSearchScreen(),
      const WorkerProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.purple,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _WorkerHome extends StatefulWidget {
  final VoidCallback onSearchRequested;
  const _WorkerHome({required this.onSearchRequested});

  @override
  State<_WorkerHome> createState() => _WorkerHomeState();
}

class _WorkerHomeState extends State<_WorkerHome> {
  @override
  Widget build(BuildContext context) {
    final user = LocalStorage().currentUser;
    final allApps = LocalStorage().getApplications();
    final myApps = allApps.where((a) => a.workerId == user?.id).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome, ${user?.username}!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: widget.onSearchRequested,
            icon: const Icon(Icons.search),
            label: const Text('Find Nearby Jobs'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 30),
          const Text('My Applications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: myApps.isEmpty 
              ? const Center(child: Text('No applications yet.'))
              : ListView.builder(
                  itemCount: myApps.length,
                  itemBuilder: (ctx, i) {
                    final app = myApps[i];
                    final job = LocalStorage().getJobs().firstWhere((j) => j.id == app.jobId);
                    return Card(
                      child: ListTile(
                        title: Text(job.type),
                        subtitle: Text('Status: ${app.status}'),
                        trailing: app.status == 'accepted' || app.status == 'selected'
                          ? IconButton(
                              icon: const Icon(Icons.chat, color: Colors.purple),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => ChatScreen(applicationId: app.id),
                                ));
                              },
                            )
                          : null,
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
