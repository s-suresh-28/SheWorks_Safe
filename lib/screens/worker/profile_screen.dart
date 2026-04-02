import 'package:flutter/material.dart';
import '../../core/storage.dart';

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({Key? key}) : super(key: key);

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  final List<String> _availableSkills = ['Cooking', 'Cleaning', 'Caretaker', 'Washing'];
  late List<String> _mySkills;

  @override
  void initState() {
    super.initState();
    _mySkills = List.from(LocalStorage().currentUser?.skills ?? []);
  }

  void _saveProfile() async {
    final user = LocalStorage().currentUser;
    if (user != null) {
      final updatedUser = user.copyWith(skills: _mySkills);
      await LocalStorage().saveUser(updatedUser);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = LocalStorage().currentUser;
    if (user == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profile Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(user.username),
            subtitle: Text('Age: ${user.age} • Rating: ${user.rating} ⭐'),
          ),
          const SizedBox(height: 20),
          const Text('My Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8.0,
            children: _availableSkills.map((skill) {
              final isSelected = _mySkills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _mySkills.add(skill);
                    } else {
                      _mySkills.remove(skill);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: const Text('Save Skills'),
          ),
          const SizedBox(height: 10),
          const Text(
            'Privacy Note: Your exact location and direct contact details are hidden from providers.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
