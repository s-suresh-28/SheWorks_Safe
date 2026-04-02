import 'package:flutter/material.dart';
import '../../core/storage.dart';
import '../../models/models.dart';
import 'package:uuid/uuid.dart';

class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({Key? key}) : super(key: key);

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  String _selectedSkillFilter = 'All';
  final List<String> _skills = ['All', 'Cooking', 'Cleaning', 'Caretaker', 'Washing'];

  void _applyJob(Job job) async {
    final user = LocalStorage().currentUser;
    if (user == null) return;

    // Check if already applied
    final apps = LocalStorage().getApplications();
    if (apps.any((a) => a.jobId == job.id && a.workerId == user.id)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Already applied to this job.')));
      return;
    }

    final newApp = JobApplication(
      id: const Uuid().v4(),
      jobId: job.id,
      workerId: user.id,
      providerId: job.providerId,
    );
    await LocalStorage().saveApplication(newApp);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application Sent!')));
    setState(() {}); // refresh UI maybe
  }

  @override
  Widget build(BuildContext context) {
    var jobs = LocalStorage().getJobs().where((j) => j.status == 'open').toList();
    
    if (_selectedSkillFilter != 'All') {
      jobs = jobs.where((j) => j.type == _selectedSkillFilter).toList();
    }

    return Column(
      children: [
        // Map Mock View
        Container(
          height: 150,
          color: Colors.blue[100],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 40, color: Colors.blueAccent),
                Text('Map View (Jobs within 3 km)'),
              ],
            ),
          ),
        ),
        // Filters
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _skills.map((skill) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(skill),
                    selected: _selectedSkillFilter == skill,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedSkillFilter = skill);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Job List
        Expanded(
          child: jobs.isEmpty
            ? const Center(child: Text('No nearby open jobs matching criteria.'))
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: jobs.length,
                itemBuilder: (ctx, i) {
                  final job = jobs[i];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(job.type, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('₹${job.salary}/mo', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Timing: ${job.timing}'),
                          const SizedBox(height: 4),
                          Text(job.description, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () => _applyJob(job),
                              child: const Text('Apply'),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}
