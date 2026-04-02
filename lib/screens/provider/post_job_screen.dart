import 'package:flutter/material.dart';
import '../../core/storage.dart';
import '../../models/models.dart';
import 'package:uuid/uuid.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({Key? key}) : super(key: key);

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  String _selectedType = 'Cooking';
  final _salaryCtrl = TextEditingController();
  final _timingCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  void _postJob() async {
    final user = LocalStorage().currentUser;
    if (user == null) return;

    if (_salaryCtrl.text.isEmpty || _timingCtrl.text.isEmpty || _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final job = Job(
      id: const Uuid().v4(),
      providerId: user.id,
      type: _selectedType,
      salary: double.tryParse(_salaryCtrl.text) ?? 0.0,
      timing: _timingCtrl.text,
      description: _descCtrl.text,
    );

    await LocalStorage().saveJob(job);
    _salaryCtrl.clear();
    _timingCtrl.clear();
    _descCtrl.clear();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job Posted Successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Post a New Job', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: const InputDecoration(labelText: 'Job Type'),
            items: ['Cooking', 'Cleaning', 'Caretaker', 'Washing']
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedType = val);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _salaryCtrl,
            decoration: const InputDecoration(labelText: 'Monthly Salary (₹)', prefixIcon: Icon(Icons.money)),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _timingCtrl,
            decoration: const InputDecoration(labelText: 'Timing (e.g. 9 AM - 5 PM)', prefixIcon: Icon(Icons.access_time)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
            maxLines: 3,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _postJob,
            child: const Text('Post Job'),
          )
        ],
      ),
    );
  }
}
