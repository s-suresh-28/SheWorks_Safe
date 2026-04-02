import 'package:flutter/material.dart';
import '../../core/storage.dart';
import '../../models/models.dart';
import '../shared/chat_screen.dart';

class ManageApplicationsScreen extends StatefulWidget {
  const ManageApplicationsScreen({Key? key}) : super(key: key);

  @override
  State<ManageApplicationsScreen> createState() => _ManageApplicationsScreenState();
}

class _ManageApplicationsScreenState extends State<ManageApplicationsScreen> {
  
  void _acceptApplication(JobApplication app) async {
    final updated = app.copyWith(status: 'accepted');
    await LocalStorage().saveApplication(updated);
    setState(() {});
  }

  void _rejectApplication(JobApplication app) async {
    final updated = app.copyWith(status: 'rejected');
    await LocalStorage().saveApplication(updated);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = LocalStorage().currentUser;
    if (user == null) return const SizedBox();

    final allApps = LocalStorage().getApplications();
    final myApps = allApps.where((a) => a.providerId == user.id).toList();

    if (myApps.isEmpty) {
      return const Center(child: Text('No applications yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: myApps.length,
      itemBuilder: (ctx, i) {
        final app = myApps[i];
        final worker = LocalStorage().getUsers().firstWhere((u) => u.id == app.workerId, orElse: () => User(id: '', username: 'Unknown', email: '', password: '', role: 'worker', isVerifiedFemale: true, age: 0));
        final job = LocalStorage().getJobs().firstWhere((j) => j.id == app.jobId, orElse: () => Job(id: '', providerId: '', type: 'Deleted Job', salary: 0, timing: '', description: ''));

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Job: ${job.type}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Applicant: ${worker.username} (Age: ${worker.age})'),
                Text('Worker Rating: ${worker.rating} ⭐'),
                Text('Status: ${app.status}', style: TextStyle(color: app.status == 'selected' ? Colors.green : Colors.black)),
                const SizedBox(height: 10),
                if (app.status == 'pending')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _rejectApplication(app),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Reject'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _acceptApplication(app),
                        child: const Text('Accept to Chat'),
                      ),
                    ],
                  ),
                if (app.status == 'accepted' || app.status == 'selected')
                   Align(
                     alignment: Alignment.centerRight,
                     child: ElevatedButton.icon(
                       onPressed: () {
                         Navigator.push(context, MaterialPageRoute(
                           builder: (_) => ChatScreen(applicationId: app.id),
                         ));
                       },
                       icon: const Icon(Icons.chat),
                       label: const Text('Open Chat'),
                     ),
                   )
              ],
            ),
          ),
        );
      },
    );
  }
}
